{ config, ... }:
{
  services.playit = {
    enable = true;
    user = "playit";
    group = "playit";
  };

  services.tshock = {
    enable = true;
    port = 13054;
    maxPlayers = 2;
    openFirewall = true;
    password = ""; # ADD SEPARATELY
  };
}