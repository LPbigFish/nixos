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
  ];

  graphics-driver-selection.gpu = "intel";

  boot.kernelPackages = pkgs.linuxPackages_6_18;

  networking.hostName = "DESKTOP-E323AF"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cz";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "cz-lat2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    wget
    scrcpy
    openconnect
    networkmanager-openconnect
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
}
