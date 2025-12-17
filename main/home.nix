{
  pkgs,
  gnomeExtensions,
  lib,
  ...
}:
let
  light_wp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/LPbigFish/nixos/refs/heads/main/.github/images/image_uw.jpg";
    sha256 = "0n20194xkwhlbizyva43698q0mmgdpdwrgrv3hmi7zbmx0lskrwc";
  };
  dark_wp = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/LPbigFish/nixos/refs/heads/main/.github/images/image_dark_uw.jpg";
    sha256 = "0y3wcdp954j3kc0wxg56mc5kmi5h8xpw1pv7vrq9qb60khw22h1m";
  };
in
{

  imports = [
    ./dconf.nix
  ];

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
      pavucontrol
      audacity
      vinegar
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
        tweaks = [
          "black"
          "primary"
          "compact"
          "dock"
        ];
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
    obs-studio = {
      enable = true;

      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ];
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

  home.file = {
    "~/.p10k.zsh".source = ../modules/.p10k.zsh;
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
