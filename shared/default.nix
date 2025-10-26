{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./nix-options.nix
    ./graphics_drivers
  ];

  programs = {
    nh = {
      enable = true;
      flake = "/home/lpbigfish/.config/nixos";
    };
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
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
      # Check if a hostname ($1) was provided
      if [ -z "$1" ]; then
        echo "Error: Please provide a hostname."
        echo "Usage: nhswitch <hostname>"
        return 1
      fi
      # Run the command with the provided hostname
      nh os switch -H "$1" .
    '')
    ]
  );

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
}
