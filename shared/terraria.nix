{ config, ... }:
{
  sops.secrets.tailscale_auth = {
    sopsFile = ../secrets/terraria.yaml;
    path = "/run/secrets/tailscale_key";
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "${config.sops.secrets.tailscale_auth.path}";
  };

  services.terraria = {
    enable = false;
    port = 13054;
    maxPlayers = 2;
    openFirewall = true;
    password = ""; # ADD SEPARATELY
  };
}