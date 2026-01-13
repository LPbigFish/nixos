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
    inputs.devkit.nixosModules.registry
    inputs.sops-config.nixosModules.sops_configuration
    inputs.disko.nixosModules.disko
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./.
    ./terraria-override.nix
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
    main = {
      inherit system pkgs;
      specialArgs = {
        gnomeExtensions = (import ./desktop/gnome-extensions.nix { inherit pkgs; });
      };
      modules = shared_modules ++ [
        inputs.grub-conf.nixosModules.grubConfiguration
        inputs.flatpak-module.nixosModules.flatpak
        ./gaming.nix
        ./desktop/gnome.nix
        ../main/configuration.nix
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
        #./media_server/terraria.nix
        #./media_server/jellyfin.nix
        ./media_server/postgresql.nix
        ./media_server/minecraft.nix
        ./media_server/nextcloud.nix
        ../orangepi5pro/configuration.nix
      ];
    };
  };
in
configurations
