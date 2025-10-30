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
    worldPath = "/var/lib/terraria/Worlds/Tota.wld";
    dataDir = "/srv/terraria";
  };

  systemd.tmpfiles.rules = [
      "d /var/lib/terraria 0750 terraria terraria - -"
    ];
}