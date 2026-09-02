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
    ./wireguard.nix
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

  services.ntp.enable = true;
  time.timeZone = "Europe/Prague";
  # OPi 5 Pro DTB (RK3588S)
  hardware.deviceTree.name = lib.mkForce "rockchip/rk3588s-orangepi-5-pro.dtb";

  # Serial console (UART2, 1.5M) is handy for debugging
  boot.kernelParams = [
    "console=ttyS2,1500000n8"
    "cma=512M"
  ];

  # SD card carries /boot (U‑Boot + kernels/extlinux)
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/d3efb2a1-300f-429a-9d95-853ecd1e3b1d";
    fsType = "ext4";
  };

  graphics-driver-selection.gpu = "none";

  networking.hostName = "orangepi5pro";
  services.openssh.enable = true;

  sops.secrets.polymarketScannerEnv = {
    sopsFile = ../../secrets/polymarket.env;
    format = "dotenv";
    owner = "root";
    group = "polymarket-scanner";
    mode = "0440";
  };

  services.polymarket-scanner = {
    enable = true;
    environmentFile = config.sops.secrets.polymarketScannerEnv.path;
    extraEnvironment = {
      INGESTION_ENABLED = "true";
      SCORING_ENABLED = "true";
      ALERTS_ENABLED = "false";
      RECEIPTS_ENABLED = "false";
      COMMANDS_ENABLED = "true";
      LEGACY_ALERTS_ENABLED = "false";
      LEGAL_REVIEW_APPROVED = "false";
    };
  };

  # deploy-rs: push closures as this user + passwordless activation
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  security.sudo-rs.wheelNeedsPassword = false;

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
    binutils
    openssl

    podman-tui
    docker-compose
  ];

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = true;
      Domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  # Match your target release
  system.stateVersion = "24.11";
}
