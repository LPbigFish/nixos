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
      url = "./modules/flatpak";
    };
    grub-conf.url = "./modules/grub";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-rk3588 = {
      url = "github:gnull/nixos-rk3588";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim-conf = {
      url = "./modules/nvim";
    };
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    sops-config.url = "./modules/sops";

    devkit.url = "./modules/devkit";

  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      mkHost =
        name: cfg:
        nixpkgs.lib.nixosSystem {
          inherit (cfg) system pkgs;
          specialArgs = {
            inherit inputs;
          }
          // cfg.specialArgs;
          modules = cfg.modules ++ [
            {
              system.autoUpgrade = {
                enable = true;
                flake = "github:LPbigFish/nixos#${name}";
                persistent = true;
                dates = "weekly";
                operation = "switch";
              };
            }
          ];
        };

      configs = import ./modules/profiles.nix { inherit inputs nixpkgs; };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkHost configs;
    };
}
