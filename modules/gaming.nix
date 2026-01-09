{ pkgs, ... }: {
  programs = {
    steam = {
      package = pkgs.steam.override {
        extraPkgs = p: with p; [
          bumblebee
          primus
        ];
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
  ];
}