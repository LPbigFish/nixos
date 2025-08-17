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
  ];

  boot.kernelParams = [
    # Improve Bluetooth throughput
    "btusb.enable_autosuspend=n"
    "btusb.enable_autosuspend_remote_wakeup=n"
  ];
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=1  # Fix LDAC stutter
    options snd_hda_intel power_save=0 # Disable audio power saving
  '';

  graphics-driver-selection.gpu = "intel";

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
    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.codecs" = [
          "ldac"
          "aac"
          "sbc"
        ];
        "bluez5.enable-ldac" = true;
        "bluez5.ldac-quality" = "hq";
        "bluez5.auto-switch" = false;
      };
    };
    extraConfig.pipewire = {
      "92-sony-ldac" = {
        "context.properties" = {
          "default.clock.rate" = 96000;
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 32;
        };
      };
    };
    wireplumber.configPackages = [
      pkgs.wireplumber
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "bredr/le";
        FastConnectable = true;
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 7;
      };
    };
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
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
}
