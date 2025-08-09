{
  config,
  lib,
  ...
}:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:wlan0" ];

  networking.interfaces.wlan0.useDHCP = false;
  networking.interfaces.wlan0.ipv4.addresses = [
    {
      address = "192.168.50.1";
      prefixLength = 27;
    }
  ];

  services.hostapd = {
    enable = true;
    radios.wlan0 = {
      countryCode = "CZ";
      band = "2g";
      channel = 9;

      settings = {
        ieee80211n = lib.mkForce "1";
        ht_capab = lib.mkForce "[SHORT-GI-20]";
        wmm_enabled = lib.mkForce "1";
      };

      networks = {
        wlan0 = {
          ssid = "OrangeBox";
          authentication = {
            mode = "wpa2-sha1";
            wpaPasswordFile = config.sops.secrets.wpaPassword.path;
          };
        };
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "wlan0";
      bind-interfaces = true;

      dhcp-authoritative = true;

      dhcp-range = "192.168.50.10,192.168.50.30,255.255.255.224,12h";

      dhcp-option = [
        "3,192.168.50.1"
        "6,192.168.50.1"
      ];

      log-dhcp = true;

      domain = "home.arpa";
      expand-hosts = true;
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "enP4p65s0";
    internalInterfaces = [ "wlan0" ];
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.allowedUDPPorts = [
    67
    68
    53
    22
  ];
  networking.firewall.allowedTCPPorts = [ 53 22 ];
}
