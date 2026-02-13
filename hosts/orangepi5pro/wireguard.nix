{ pkgs, ... }:
{

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.2/24" ];
      listenPort = 51820;

      privateKeyFile = "/etc/wireguard/private.key";

      peers = [
        {
          publicKey = "JK+BwkTEpVUSVoKwa2TRi1Q6MQd0YNovuFKXNAT4MyU=";
          allowedIPs = [ "10.100.0.1/32" ];
          endpoint = "37.120.168.146:51820";
          persistentKeepalive = 25;
        }

      ];
    };
  };

  networking.firewall.trustedInterfaces = [ "wg0" ];
}
