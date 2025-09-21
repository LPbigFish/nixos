{ nixpkgs, inputs }:
let
  system = "x86_64-linux";
  rk_system = "aarch64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  rk_pkgsKernel = import nixpkgs {
    system = rk_system;
    overlays = [
      (import ../overlays/rk-overlay.nix)
    ];
    config.allowUnfree = true;
  };

  shared_modules = [
    inputs.devkit.nixosModules.registry
    inputs.sops-config.nixosModules.sops_configuration
    inputs.disko.nixosModules.disko
    ./.
    ./user-group.nix
  ];

  configurations = {
    wsl = {
      inherit system pkgs;
      modules = shared_modules ++ [
        ../wsl/configuration.nix
        inputs.nixos-wsl.nixosModules.default
      ];
      specialArgs = { };
    };
    laptop = {
      inherit system pkgs;
      specialArgs = {
        gnomeExtensions = (import ./desktop/gnome-extensions.nix { inherit pkgs; });
      };
      modules = shared_modules ++ [
        inputs.grub-conf.nixosModules.grubConfiguration
        inputs.flatpak-module.nixosModules.flatpak
        ./gaming.nix
        ./desktop/gnome.nix
        ../disk-config.nix
        ../laptop/configuration.nix
      ];
    };
    minimal = {
      inherit system pkgs;
      modules = shared_modules ++ [
        inputs.grub-conf.nixosModules.grubConfiguration
        ../disk-config.nix
        ../minimal/configuration.nix
      ];
      specialArgs = {
        swapSize = "8G";
      };
    };

    orangepi5pro = {
      system = rk_system;
      pkgs = rk_pkgsKernel;

      specialArgs = {
        rk3588 = {
          inherit nixpkgs;
          pkgsKernel = rk_pkgsKernel;
        };
      };
      modules = shared_modules ++ [
        inputs.nixos-rk3588.nixosModules.boards.orangepi5.core
        inputs.disko.nixosModules.disko
        ./tor_services.nix
        ./monerod.nix
        ./media_server/jellyfin.nix
        # ./media_server/nextcloud.nix
        ../orangepi5pro/configuration.nix
      ];
    };
  };
in
configurations
