{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    flatpak-module = {
      url = "./shared/flatpak";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    grub-conf = {
      url = "./shared/grub";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-wsl,
      flatpak-module,
      grub-conf,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: _prev: {
            unstable = import nixpkgs-unstable {
              inherit (final) system config;
            };
          })
        ];
      };

      shared_modules = [
				./shared/generic.nix
        ./shared/graphics_drivers
      ];
    in
    {
      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
					inherit system pkgs;
          specialArgs = { inherit inputs; };
          modules = shared_modules ++ [
            ./wsl/configuration.nix
            nixos-wsl.nixosModules.default
          ];
        };

				laptop = nixpkgs.lib.nixosSystem {
					inherit system pkgs;
          specialArgs = { inherit inputs; };
          modules = shared_modules ++ [
            grub-conf.nixosModules.grubConfiguration
            flatpak-module.nixosModules.flatpak
						./shared/desktop/gnome.nix
            ./laptop/configuration.nix
						./hardware-configuration.nix
          ];
        };
      };
    };
}
