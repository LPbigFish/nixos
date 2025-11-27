{ pkgs, ... }:
{
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.v4l-utils

    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  users.users.jellyfin = {
    isSystemUser = true;
    extraGroups = [ "video" "render" ];
  };

  systemd.services.jellyfin.serviceConfig = {
    # Jellyfin’s ffmpeg needs these /dev nodes
    PrivateDevices = false;
    DeviceAllow = [
      "/dev/mpp_service rw"
      "/dev/rga rw"
      "/dev/dri rw"
      "/dev/dma_heap rw"
      "/dev/dma_heap/system rw"
      "/dev/dma_heap/cma rw"
      # Optional, if present on your kernel:
      "/dev/dma_heap/system-uncached rw"
      # Some kernels expose V4L2 nodes for RGA/VPU as /dev/video*
      "/dev/video0 rw"
      "/dev/video1 rw"
    ];
    SupplementaryGroups = [ "video" "render" ];
  };
}
