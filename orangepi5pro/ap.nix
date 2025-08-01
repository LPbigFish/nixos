{ config, pkgs, ... }:

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
        ieee80211n = "1"; # keep 11n
        ht_capab = "[SHORT-GI-20]"; # no [HT40+/-], no [SHORT-GI-40]
        wmm_enabled = "1"; # recommended for 11n
      };
      
      networks = {
        wlan0 = {
          ssid = "OrangeBox";
          authentication = {
            mode = "wpa2-sha256";
            wpaPassword = "12345678"; # use wpaPassphrase here
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

      # 192.168.50.0/27 → mask 255.255.255.224, usable .1-.30
      # Serve .2-.30 to clients for 12h leases
      dhcp-range = "192.168.50.2,192.168.50.30,255.255.255.224,12h";

      # Default gateway & DNS given to clients
      dhcp-option = [
        "3,192.168.50.1" # router (option 3)
        "6,1.1.1.1,9.9.9.9" # DNS servers (option 6)
      ];
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
