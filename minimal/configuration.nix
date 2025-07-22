{ config, pkgs, lib, ... }: {
  imports = [
    ./disk-config.nix
  ];

  networking.hostName = "DESKTOP-E323AF"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
}