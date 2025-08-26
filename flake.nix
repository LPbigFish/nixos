{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    flatpak-module = {
      url = "./shared/flatpak";
    };
    grub-conf.url = "./shared/grub";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-rk3588 = {
      url = "github:gnull/nixos-rk3588";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-config.url = "./shared/sops";

    devkit.url = "./shared/devkit";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      shared_modules = [
        inputs.devkit.nixosModules.registry
        inputs.sops-config.nixosModules.sops_configuration
        inputs.disko.nixosModules.disko
        ./shared/generic.nix
        ./shared/user-group.nix
      ];

      rk_system = "aarch64-linux";
      rk_pkgsKernel = import nixpkgs {
        system = rk_system;
        overlays = [
          (import ./overlays/rk-overlay.nix)
        ];
        config.allowUnfree = true;
      };

      boardModule = inputs.nixos-rk3588.nixosModules.boards.orangepi5;

    in
    {
      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = { inherit inputs; };
          modules = shared_modules ++ [
            ./wsl/configuration.nix
            inputs.nixos-wsl.nixosModules.default
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = {
            inherit inputs;
            gnomeExtensions =
              (import ./shared/desktop/gnome-extensions.nix { inherit pkgs; });
          };
          modules = shared_modules ++ [
            inputs.grub-conf.nixosModules.grubConfiguration
            inputs.flatpak-module.nixosModules.flatpak
            ./disk-config.nix
            ./shared/gaming.nix
            ./shared/desktop/gnome.nix
            ./laptop/configuration.nix
            ./hardware-configuration.nix
          ];
        };

        minimal = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          specialArgs = {
            inherit inputs;
            swapSize = "8G";
          };
          modules = shared_modules ++ [
            inputs.grub-conf.nixosModules.grubConfiguration
            ./disk-config.nix
            ./minimal/configuration.nix
            ./hardware-configuration.nix
          ];
        };
        orangepi5pro = nixpkgs.lib.nixosSystem {
          system = rk_system;
          pkgs = rk_pkgsKernel;
          specialArgs = {
            inherit inputs;
            rk3588 = {
              inherit nixpkgs;
              pkgsKernel = rk_pkgsKernel;
            };
          };
          modules = shared_modules ++ [
            boardModule.core
            inputs.disko.nixosModules.disko
            ./shared/media_server/jellyfin.nix
            ./orangepi5pro/configuration.nix
          ];
        };
      };
    };
}
