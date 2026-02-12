{ nixpkgs, inputs }:
let
  system = "x86_64-linux";
  rk_system = "aarch64-linux";

  overlays = [
    (import ../overlays/rk-overlay.nix)
    (import ../overlays/generic-overlay.nix)
    inputs.nix-minecraft.overlay
    inputs.vim-conf.overlays.default
  ];

  pkgs = import nixpkgs {
    inherit system overlays;
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
      cudaSupport = true;
    };
  };

  rk_pkgsKernel = import nixpkgs {
    inherit overlays;
    system = rk_system;
    config.allowUnfree = true;
  };

  shared_modules = [
    {
      disabledModules = [ "services/games/terraria.nix" ];
      nix.settings = {
      };
    }
    inputs.disko.nixosModules.disko
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./.
  ];

  configurations = {
    wsl = {
      inherit system pkgs;
      modules = shared_modules ++ [
        ../hosts/wsl/configuration.nix
        inputs.nixos-wsl.nixosModules.default
        inputs.sops-config.nixosModules.sops_configuration
      ];
      specialArgs = { };
    };
    main = {
      inherit system pkgs;
      specialArgs = {
        gnomeExtensions = (import ./desktop/gnome-extensions.nix { inherit pkgs; });
      };
      modules = shared_modules ++ [
        inputs.grub-conf.nixosModules.grubConfiguration
        inputs.flatpak-module.nixosModules.flatpak
        inputs.sops-config.nixosModules.sops_configuration
        ./gaming.nix
        ./desktop/gnome.nix
        ../hosts/main/configuration.nix
        ./user-group.nix
      ];
    };
    laptop = {
      inherit system pkgs;
      specialArgs = {
        gnomeExtensions = (import ./desktop/gnome-extensions.nix { inherit pkgs; });
      };
      modules = shared_modules ++ [
        inputs.grub-conf.nixosModules.grubConfiguration
        inputs.flatpak-module.nixosModules.flatpak
        inputs.sops-config.nixosModules.sops_configuration
        ./gaming.nix
        ./desktop/gnome.nix
        ../disk-config.nix
        ../hosts/laptop/configuration.nix
        ./user-group.nix
      ];
    };
    minimal = {
      inherit system pkgs;
      modules = shared_modules ++ [
        inputs.grub-conf.nixosModules.grubConfiguration
        inputs.sops-config.nixosModules.sops_configuration
        ../disk-config.nix
        ../hosts/minimal/configuration.nix
        ./user-group.nix
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
        inputs.sops-config.nixosModules.sops_configuration
        ./tor_services.nix
        ./monerod.nix
        #./media_server/terraria.nix
        #./media_server/jellyfin.nix
        ./media_server/postgresql.nix
        ./media_server/minecraft.nix
        ./media_server/nextcloud.nix
        ./media_server/moodle.nix
        ../hosts/orangepi5pro/configuration.nix
        ./user-group.nix
      ];
    };
    netcup = {
      inherit system pkgs;
      modules = shared_modules ++ [
        ../hosts/netcup/configuration.nix
      ];
    };
  };
in
configurations
