{
  pkgs,
  inputs,
  gnomeExtensions,
  ...
}:
{

  imports = [
    # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ./hardware-configuration.nix
    ./pipewire.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelModules = [ "snd-hda-intel" ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=generic
  '';

  graphics-driver-selection.gpu = "nvidia";

  networking.hostName = "DESKTOP-JWEF21";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Prague";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.UTF-8";
    LC_IDENTIFICATION = "cs_CZ.UTF-8";
    LC_MEASUREMENT = "cs_CZ.UTF-8";
    LC_MONETARY = "cs_CZ.UTF-8";
    LC_NAME = "cs_CZ.UTF-8";
    LC_NUMERIC = "cs_CZ.UTF-8";
    LC_PAPER = "cs_CZ.UTF-8";
    LC_TELEPHONE = "cs_CZ.UTF-8";
    LC_TIME = "cs_CZ.UTF-8";
  };

  services.xserver.xkb = {
    layout = "cz";
    variant = "";
  };

  console.keyMap = "cz-lat2";

  services.printing.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.trackpoint.emulateWheel = true;

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  home-manager = {
    extraSpecialArgs = { inherit inputs pkgs gnomeExtensions; };
    users = {
      "lpbigfish" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  programs.obs-studio.enableVirtualCamera = true;

  programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
      settings = {
        global = {
          hide_env_diff = true;
        };
      };
    };

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    scrcpy
    openconnect
    networkmanager-openconnect
    qpwgraph
    easyeffects
    rquickshare
    dive
    podman-tui
    docker-compose
    bottles
    unzip
    zip
  ];

  system.stateVersion = "25.05";
}
