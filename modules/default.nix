{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./graphics_drivers
  ];

  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--keep 1 --no-gcroots";
      };
      flake = "/home/lpbigfish/.config/nixos";
    };
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld;
    };
    direnv.enable = true;
  };

  environment.shellAliases = {
    nhclean = "nh clean all -k 1 --no-gcroots";
  };

  services.timesyncd.enable = true;

  fonts = {
    packages = [
      pkgs.nerd-fonts.meslo-lg
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "MesloLGL Nerd Font" ];
        monospace = [ "MesloLGL Nerd Font Mono" ];
      };
    };
  };

  environment.systemPackages = lib.mkBefore (
    with pkgs;
    [
      nano
      vim
      btop
      nixd
      nixfmt-rfc-style
      git
      git-lfs
      screen
      sudo-rs
      nvd
      (writeShellScriptBin "nhswitch" ''
        #!/usr/bin/env bash

        if [ -z "$1" ]; then
          echo "Error: Please provide a hostname."
          echo "Usage: nhswitch <hostname>"
          exit 1
        fi

        nh os switch -H "$1" .
      '')
    ]
  );

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      package = pkgs.sudo-rs;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos-cuda.org"
        #"https://app.cachix.org/cache/nix-community"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };
}
