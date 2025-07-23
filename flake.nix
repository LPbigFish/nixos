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
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      flatpak-module,
      grub-conf,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      shared_modules = [
        ./shared/generic.nix
        disko.nixosModules.disko
      ];
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
          specialArgs = { inherit inputs; swapSize = "8G"; };
          modules = shared_modules ++ [
            grub-conf.nixosModules.grubConfiguration
            ./shared/graphics_drivers
            ./disk-config.nix
            ./minimal/configuration.nix
            ./hardware-configuration.nix
          ];
        };
      };
    };
}
