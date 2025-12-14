{pkgs, inputs, gnomeExtensions, ...}: {

imports = [
    # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ./pipewire.nix
  ];

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

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs pkgs gnomeExtensions; };
    users = {
      "lpbigfish" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    scrcpy
    openconnect
    networkmanager-openconnect
  ];

}