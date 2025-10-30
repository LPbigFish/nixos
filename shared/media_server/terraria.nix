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
    port = 13054;
    maxPlayers = 2;
    openFirewall = true;
    password = ""; # ADD SEPARATELY
    worldPath = "/var/lib/terraria/wld/Tota.wld";
  };
}