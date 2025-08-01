{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Let NetworkManager manage everything EXCEPT the AP interface
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:wlan0" ];

  # Give the AP interface a static /27 address and disable DHCP client on it
  networking.interfaces.wlan0.useDHCP = false;
  networking.interfaces.wlan0.ipv4.addresses = [
    {
      address = "192.168.50.1";
      prefixLength = 27;
    } # 192.168.50.0/27
  ];

  # Hostapd: Wi-Fi AP
  services.hostapd = {
    enable = true;
    # New-style, declarative radios/networks
    radios.wlan0 = {
      countryCode = "CZ"; # <-- set your 2-letter code (e.g., DE, GB)
      band = "2g"; # or "5g" if your chip supports it
      channel = 9; # pick a legal, uncongested channel

      settings = {
        ieee80211n = lib.mkForce "1";
        ht_capab = lib.mkForce "[SHORT-GI-20]"; # 20 MHz only, no SGI-40
        wmm_enabled = lib.mkForce "1";
      };

      networks = {
        wlan0 = {
          ssid = "OrangeBox";
          authentication = {
            mode = "wpa3-sae-transition";
            wpaPassword = "123456789";
            saePasswords = [ { password = "123456789"; } ];
          };
          settings = {
            ieee80211w = "1"; # PMF optional for transition
            sae_pwe = "2"; # better Android compatibility
            wpa_key_mgmt = "SAE WPA-PSK"; # <-- replace WPA-PSK-SHA256 with WPA-PSK
          };
        };
      };
    };
  };

  # DHCP (and DNS) for the AP subnet via dnsmasq
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "wlan0";
      bind-interfaces = true;

      # Be authoritative for this link → clients pick up changes faster
      dhcp-authoritative = true;

      # Local zone
      domain = "home.arpa";
      local = "/home.arpa/";
      expand-hosts = true;

      # Hand out the Pi as gateway and DNS
      dhcp-option = [
        "3,192.168.50.1" # router
        "6,192.168.50.1" # DNS = the Pi
        "15,home.arpa" # domain (search)
        "119,home.arpa" # search list (not all clients use it)
      ];

      # Host record
      host-record = [ "orangepi.home.arpa,192.168.50.1" ];

      # Debugging
      log-queries = true;
      log-dhcp = true;
    };
  };

  # (Optional) Share WAN to Wi-Fi clients with NAT via eth0
  networking.nat = {
    enable = true;
    externalInterface = "enP4p65s0"; # <-- your uplink
    internalInterfaces = [ "wlan0" ];
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Firewall: allow DHCP/DNS from clients (and let NAT handle forwarding)
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [
      67
      68
      53
      22
    ];
    allowedTCPPorts = [
      53
      22
    ];
  };
}
