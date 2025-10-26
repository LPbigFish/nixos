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

    vim-conf = {
      url = "./shared/nvim";
    };

    sops-config.url = "./shared/sops";

    devkit.url = "./shared/devkit";

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
                dates = "daily";
                operation = "switch";
              };
            }
          ];
        };

      configs = import ./shared/profiles.nix { inherit inputs nixpkgs; };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkHost configs;
    };
}
