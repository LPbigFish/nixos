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
    worldPath = "Tota.wld";
    dataDir = "/srv/terraria";
  };
}