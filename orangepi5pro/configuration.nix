{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./led-overlay.nix
    ./orange-disk.nix
    ./ap.nix
  ];

  services.udev.extraRules = ''
    KERNEL=="mpp_service", MODE="0660", GROUP="video"
    KERNEL=="rga",         MODE="0660", GROUP="video"
    SUBSYSTEM=="dma_heap", KERNEL=="system*", MODE="0666", GROUP="video"
  '';

  # U‑Boot + extlinux (not GRUB/systemd-boot)
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.networkmanager.enable = true;

  # OPi 5 Pro DTB (RK3588S)
  hardware.deviceTree.name = lib.mkForce "rockchip/rk3588s-orangepi-5-pro.dtb";

  # Serial console (UART2, 1.5M) is handy for debugging
  boot.kernelParams = [ "console=ttyS2,1500000n8" ];

  # SD card carries /boot (U‑Boot + kernels/extlinux)
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/d3efb2a1-300f-429a-9d95-853ecd1e3b1d";
    fsType = "ext4";
  };

  graphics-driver-selection.gpu = "none";

  networking.hostName = "orangepi5pro";
  services.openssh.enable = true;

  users.users.lpbigfish = {
    isNormalUser = true;
    description = "LPbigFish";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    createHome = true;
    hashedPasswordFile = config.sops.secrets."defaultUserPassword".path;
    packages = with pkgs; [ ];
  };

  users.users.root.hashedPasswordFile = config.sops.secrets."defaultUserPassword".path;

  environment.systemPackages = with pkgs; [
    util-linux
    curl
    zip
    xz
    unzip
    zstd
    gnutar

    # misc
    file
    which
    tree
    gnused
    gawk
    tmux
  ];

  # Match your target release
  system.stateVersion = "24.11";
}
