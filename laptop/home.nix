{
  lib,
  config,
  pkgs,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lpbigfish";
  home.homeDirectory = "/home/lpbigfish";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs.unstable; [
    (with jetbrains; [
      idea-ultimate
      clion
      rust-rover
      rider
    ])
    mullvad-vpn
    brave
    gnome-tweaks
    nil
    libreoffice-qt
    hunspell
    hunspellDicts.cs_CZ
  ];

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Orchis-Dark-Compact";
      package = pkgs.unstable.orchis-theme;
    };
  };

  programs = {
    vscode = {
      enable = true;
      package = pkgs.unstable.vscode-fhs;
    };
    gnome-shell = {
      enable = true;
      extensions = [
        { package = pkgs.unstable.gnomeExtensions.user-themes; }
        { package = pkgs.unstable.gnomeExtensions.lockscreen-extension; }
      ];
    };
    git = {
      enable = true;
      userEmail = "lpbyblock@gmail.com";
      userName = "LPbigFish";
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles
  home.file = {

  };

  home.sessionVariables = {
    # EDITOR = "nano";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
