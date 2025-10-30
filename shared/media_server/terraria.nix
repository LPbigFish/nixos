{ config, ... }:
{
  sops.secrets.secret_key = {
    owner = "playit";
    sopsFile = ../../secrets/terraria.yaml;
  };

  services.playit = {
    enable = true;
    user = "playit";
    group = "playit";
    secretPath = config.sops.secrets.secret_key.path;
  };

  services.terraria = {
    enable = true;
    maxPlayers = 2;
    openFirewall = true;
    password = "";
    worldPath = "/var/lib/terraria/wld/Toťa.wld";
  };

  networking.firewall = {
    allowedUDPPorts = [ 7777 ];
    allowedTCPPorts = [ 7777 ];
  };

  systemd.tmpfiles.rules = [
      "d /var/lib/terraria 0750 terraria terraria - -"
    ];
}