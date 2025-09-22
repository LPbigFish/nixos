{
  pkgs,
  gnomeExtensions,
  ...
}:
let
  light_wp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/LPbigFish/nixos/refs/heads/main/.github/images/light_image.jpg";
    sha256 = "1b8lfq0mg3swi45zcxlg71zv3svw1f3ff4qdgxwv3w9sbpfjn0k7";
  };
  dark_wp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/LPbigFish/nixos/refs/heads/main/.github/images/dark_image.jpg";
    sha256 = "1d0yxj5d1mak9fvxsh49g6vcx0q5almjyhqqay06cw21s1qdjqw8";
  };
in
{
  imports = [
    ./dconf.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lpbigfish";
  home.homeDirectory = "/home/lpbigfish";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
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
      android-studio
      davinci-resolve
    ])
    ++ (with pkgs.jetbrains; [
      idea-ultimate
      clion
      rider
      datagrip
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
      package = pkgs.orchis-theme;
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
      userEmail = "lpbyblock@gmail.com";
      userName = "LPbigFish";
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
      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # General
        POWERLEVEL9K_BACKGROUND='#F7F7F7'
        POWERLEVEL9K_FOREGROUND='#1C1C1C'

        # OS logo
        POWERLEVEL9K_OS_ICON_BACKGROUND='#FFFFFF'
        POWERLEVEL9K_OS_ICON_FOREGROUND='#1C1C1C'

        # Directory
        POWERLEVEL9K_DIR_BACKGROUND='#FFFFFF'
        POWERLEVEL9K_DIR_FOREGROUND='#1C1C1C'
        POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#1C1C1C'

        # VCS (git)
        POWERLEVEL9K_VCS_CLEAN_BACKGROUND='#E8E8E8'
        POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#1C1C1C'
        POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='#E8E8E8'
        POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#7F7F7F'
        POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='#E8E8E8'
        POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#7F7F7F'

        # Status segment
        POWERLEVEL9K_STATUS_OK_BACKGROUND='#FFFFFF'
        POWERLEVEL9K_STATUS_OK_FOREGROUND='#7F7F7F'
      '';
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = gnomeExtensions.extensionUuidList;
      };

      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/background" = {
        picture-uri = "file://${light_wp}";
        picture-uri-dark = "file://${dark_wp}";
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles
  home.file = {
    "~/.p10k.zsh".source = ../shared/.p10k.zsh;
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
