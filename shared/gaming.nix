{ pkgs, config, ... }: {
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    modrinth-app
    mangohud
    protonup-rs
    heroic
    bottles
    lutris
  ];
}