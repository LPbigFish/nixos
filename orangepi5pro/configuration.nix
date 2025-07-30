{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./orange-disk.nix
  ];

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

  services.udev.extraRules = ''
    SUBSYSTEM=="leds", ACTION=="add", ATTR{trigger}="none", ATTR{brightness}="0"
  '';

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
    initialPassword = "1234";
    packages = with pkgs; [ ];
  };

  users.users.root.initialPassword = "1234";

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

    
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # Match your target release
  system.stateVersion = "24.11";
}
