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
            mode = "wpa2-sha1";
            wpaPassword = config.sops.secrets."wpaPassword";
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

      # Make dnsmasq the authority for this subnet
      dhcp-authoritative = true;

      # 192.168.50.0/27  -> usable .1-.30; serve .10-.30
      dhcp-range = "192.168.50.10,192.168.50.30,255.255.255.224,12h";

      # Hand out gateway & DNS (use the AP itself as DNS)
      dhcp-option = [
        "3,192.168.50.1" # default route
        "6,192.168.50.1" # DNS server
      ];

      # Helpful for visibility while debugging
      log-dhcp = true;

      domain = "home.arpa";
      expand-hosts = true;
    };
  };

  # (Optional) Share WAN to Wi-Fi clients with NAT via eth0
  networking.nat = {
    enable = true;
    externalInterface = "enP4p65s0"; # <-- your uplink
    internalInterfaces = [ "wlan0" ];
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Firewall must allow DHCP/DNS from clients
  networking.firewall.allowedUDPPorts = [
    67
    68
    53
    22
  ];
  networking.firewall.allowedTCPPorts = [ 53 22 ];
}
