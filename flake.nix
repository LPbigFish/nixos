{
  description = "LPbigFish NixOS fleet";

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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    polymarket-scanner = {
      url = "git+ssh://git@github.com/LPbigFish/PolymarketScanner.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vim-conf = {
      url = "./modules/nvim";
    };

    sops-config.url = "./modules/sops";

    devkit.url = "./modules/devkit";

    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      infra = import ./infra { inherit lib; };

      mkHost =
        name: cfg:
        nixpkgs.lib.nixosSystem {
          inherit (cfg) system pkgs;
          specialArgs = {
            inherit inputs infra;
            hostName = name;
          }
          // cfg.specialArgs;
          modules = cfg.modules ++ [
            {
              system.autoUpgrade = {
                # deploy-rs owns activation on infrastructure hosts,
                # so their auto-upgrade is disabled to avoid fights.
                enable = !((infra.hosts.${name} or { }).deploy or false);
                flake = "github:LPbigFish/nixos#${name}";
                persistent = true;
                dates = "weekly";
                operation = "switch";
              };
            }
          ];
        };

      configs = import ./modules/profiles.nix { inherit inputs nixpkgs; };

      deployHosts = lib.filterAttrs (_: host: host.deploy or false) infra.hosts;
    in
    {
      nixosConfigurations = lib.mapAttrs mkHost configs;

      deploy.nodes = lib.mapAttrs (
        name: host:
        {
          hostname = host.sshHostname;
          sshUser = host.sshUser;
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.${host.system}.activate.nixos self.nixosConfigurations.${name};
          };
        }
        // lib.optionalAttrs ((host.sshProxyJump or null) != null) {
          sshOpts = [
            "-J"
            host.sshProxyJump
          ];
        }
      ) deployHosts;

      checks = lib.mapAttrs (
        system: deployLib:
        deployLib.deployChecks {
          nodes = lib.filterAttrs (name: _: deployHosts.${name}.system == system) self.deploy.nodes;
        }
      ) inputs.deploy-rs.lib;
    };
}
