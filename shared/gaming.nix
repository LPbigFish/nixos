{ pkgs, config, ... }: {
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs.unstable; [
    mangohud
    protonup-rs
    heroic
    bottles
    lutris
  ];
}