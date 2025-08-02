{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    flatpak-module = {
      url = "./shared/flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
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

    devkit = {
      url = "./shared/devkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      flatpak-module,
      grub-conf,
      disko,
      nixos-rk3588,
      sops-config,
      devkit,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      shared_modules = [
        devkit.nixosModules.registry
        sops-config.nixosModules.sops_configuration
        ./shared/generic.nix
        disko.nixosModules.disko
      ];

      rk_system = "aarch64-linux";
      rk_pkgsKernel = import nixpkgs { system = rk_system; };

      boardModule = nixos-rk3588.nixosModules.boards.orangepi5;

      rk_overlay = (import ./overlays/rk-overlay.nix);
    in
    {
      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = shared_modules ++ [
            ./wsl/configuration.nix
            nixos-wsl.nixosModules.default
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = shared_modules ++ [
            grub-conf.nixosModules.grubConfiguration
            flatpak-module.nixosModules.flatpak
            ./disk-config.nix
            ./shared/gaming.nix
            ./shared/graphics_drivers
            ./shared/desktop/gnome.nix
            ./laptop/configuration.nix
            ./hardware-configuration.nix
          ];
        };

        minimal = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            swapSize = "8G";
          };
          modules = shared_modules ++ [
            grub-conf.nixosModules.grubConfiguration
            ./shared/graphics_drivers
            ./disk-config.nix
            ./minimal/configuration.nix
            ./hardware-configuration.nix
          ];
        };
        orangepi5pro = nixpkgs.lib.nixosSystem {
          system = rk_system; # "aarch64-linux"
          pkgs = import nixpkgs {
            system = rk_system;
            overlays = [
              (import ./overlays/rk-overlay.nix)
            ];
            config = {
              allowUnfree = true;
              # optional: allowedUnfreePredicate = pkg: true;  # or narrow it down
            };
          };
          specialArgs = {
            inherit inputs;
            rk3588 = {
              inherit nixpkgs;
              pkgsKernel = rk_pkgsKernel;
            };
          };
          modules = shared_modules ++ [
            boardModule.core
            disko.nixosModules.disko
            ./shared/media_server/jellyfin.nix
            ./orangepi5pro/configuration.nix
          ];
        };
      };
    };
}
