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
    protontricks
    prismlauncher
    xautoclick
    protonup-qt
    jdk25
    adwaita-icon-theme
    gdk-pixbuf
    librsvg
    glycin-loaders
  ];

  networking.extraHosts = ''
    0.0.0.0 paradise-s1.battleye.com
    0.0.0.0 test-s1.battleye.com
    0.0.0.0 paradiseenhanced-s1.battleye.com
  '';
}
