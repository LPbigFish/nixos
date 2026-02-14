{ pkgs, ... }:
{
  programs = {
    steam = {
      package = pkgs.steam.override {
      };
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-rs
    heroic
    lutris
    protontricks
    prismlauncher
    xautoclick
  ];
}
