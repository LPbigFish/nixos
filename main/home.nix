{
  pkgs,
  gnomeExtensions,
  ...
}:
{
  home.username = "lpbigfish";
  home.homeDirectory = "/home/lpbigfish";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.05";

  home.packages =
    (with pkgs; [
      (discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      zsh-powerlevel10k
      mullvad-vpn
      brave
      gnome-tweaks
      libreoffice-qt
      hunspell
      hunspellDicts.cs_CZ
      hunspellDicts.en_US
      android-studio
      davinci-resolve
    ])
    ++ (with pkgs.jetbrains; [
      idea-ultimate
      clion
      rider
      datagrip
      pycharm-professional
    ])
    ++ gnomeExtensions.extensions;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Orchis-Dark";
      package = pkgs.orchis-theme.override {
        tweaks = [ "black" "primary" "compact" "dock" ];
      };
    };
  };

  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscode;
    };
    gnome-shell = {
      enable = true;
    };
    git = {
      enable = true;
      settings.user = {
        email = "lpbyblock@gmail.com";
        name = "LPbigFish";
      };
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      initContent = builtins.readFile ./zsh_init.bash;
    };
  };

  home.file = {
    "~/.p10k.zsh".source = ../modules/.p10k.zsh;
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
