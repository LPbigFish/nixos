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
    grub-conf = {
      url = "./shared/grub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-rk3588 = {
      url = "github:gnull/nixos-rk3588";
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
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      shared_modules = [
        ./shared/generic.nix
        disko.nixosModules.disko
      ];

      rk_system = "aarch64-linux";
      rk_pkgsKernel = import nixpkgs { system = rk_system; };

      boardModule = nixos-rk3588.nixosModules.orangepi5;
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
        opi5pro = nixpkgs.lib.nixosSystem {
          system = rk_system;
          specialArgs = {
            inherit inputs;
            rk3588 = { inherit nixpkgs rk_pkgsKernel; };
          };
          modules = [
            # Board: core + U‑Boot (sd-image). We stay off UEFI entirely.
            boardModule.core
            boardModule.sd-image

            # Disko for declarative NVMe partitioning/mounts
            disko.nixosModules.disko
            ./orangepi5pro/configuration.nix
          ];
        };
      };
    };
}
