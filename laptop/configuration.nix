{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      inputs.home-manager.nixosModules.default
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
  # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;

      dedsec-theme = {
        enable = true;
        style = "comments";
        icon = "color";
        resolution = "1080p";
    };
  };
};

  boot.loader.efi.canTouchEfiVariables = true;

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];

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

  hardware.graphics = {
	enable = true;
	extraPackages = with pkgs; [ vaapiIntel intel-media-driver ];
  };
  # Configure console keymap
  console.keyMap = "cz-lat2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.lpbigfish = {
    isNormalUser = true;
    description = "LPbigFish";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  home-manager = {
	extraSpecialArgs = { inherit inputs pkgs; };
	users = {
		"lpbigfish" = import ./home.nix;
	};
  };

  services.mullvad-vpn.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    wget
    nixfmt-rfc-style
   ];

  system.stateVersion = "25.05"; # Did you read the comment?

}