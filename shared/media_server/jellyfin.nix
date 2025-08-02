{ lib, pkgs, ... }:
{
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = [
    pkgs.v4l-utils

    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "video" "render" ];
    PrivateDevices = lib.mkForce false;
    DeviceAllow = [
      "/dev/mpp_service rw"
      "/dev/rga rw"
      "/dev/dri/renderD128 rw"
    ];
  };
}
