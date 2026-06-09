{
  config,
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

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
  boot.kernelModules = [ "snd-hda-intel" ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=generic
  '';

  graphics-driver-selection.gpu = "nvidia";

  networking.hostName = "DESKTOP-JWEF21";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Prague";

  nix.settings.trusted-users = [
    "root"
    "lpbigfish"
  ];

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

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    xone.enable = true;
  };

  hardware.trackpoint.emulateWheel = true;

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.enableExcludeWrapper = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  sops.secrets.opencode = {
    sopsFile = ../../secrets/opencode.yaml;
    format = "yaml";
    key = "data";
    path = "/home/lpbigfish/.config/opencode/opencode.json";
    owner = config.users.users.lpbigfish.name;
  };

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
    dive
    podman-tui
    docker-compose
    unzip
    zip
    unrar
    rar
    distrobox
    nodejs
  ];

  system.stateVersion = "25.05";
}
