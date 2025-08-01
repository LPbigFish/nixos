{ config, pkgs, interface ? "wlan0", ... }:

{
  # Let NetworkManager manage everything EXCEPT the AP interface
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:${interface}" ];

  # Give the AP interface a static /27 address and disable DHCP client on it
  networking.interfaces.${interface}.useDHCP = false;
  networking.interfaces.${interface}.ipv4.addresses = [
    { address = "192.168.50.1"; prefixLength = 27; }  # 192.168.50.0/27
  ];

  # Hostapd: Wi-Fi AP
  services.hostapd = {
    enable = true;
    # New-style, declarative radios/networks
    radios.${interface} = {
      countryCode = "CZ";    # <-- set your 2-letter code (e.g., DE, GB)
      band = "2g";           # or "5g" if your chip supports it
      channel = 9;           # pick a legal, uncongested channel
      networks = [{
        ssid = "OrangeBox";       # <-- your SSID
        authentication = {
          mode = "wpa2";     # or "wpa3" if clients support it
          wpaPassword = "12345678";  # 8+ chars
        };
      }];
    };
  };

  # DHCP (and DNS) for the AP subnet via dnsmasq
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "${interface}";
      bind-interfaces = true;

      # 192.168.50.0/27 → mask 255.255.255.224, usable .1-.30
      # Serve .2-.30 to clients for 12h leases
      dhcp-range = "192.168.50.2,192.168.50.30,255.255.255.224,12h";

      # Default gateway & DNS given to clients
      dhcp-option = [
        "3,192.168.50.1"             # router (option 3)
        "6,1.1.1.1,9.9.9.9"          # DNS servers (option 6)
      ];
    };
  };

  # (Optional) Share WAN to Wi-Fi clients with NAT via eth0
  networking.nat = {
    enable = true;
    externalInterface = "eth0";       # <-- your uplink
    internalInterfaces = [ "${interface}" ];
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Firewall: allow DHCP/DNS from clients (and let NAT handle forwarding)
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 67 68 53 22 ];
    allowedTCPPorts = [ 53 22 ];
  };
}