{ lib, pkgs, ... }:
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
    PrivateDevices = lib.mkForce false;   # expose host /dev
    DevicePolicy   = lib.mkForce "auto";
    DeviceAllow = [
      "/dev/mpp_service rw"
      "/dev/rga rw"
      "/dev/dri/renderD128 rw"
      "/dev/dri/renderD129 rw"
      "/dev/dri/renderD130 rw"
    ];
    SupplementaryGroups = [ "video" "render" ];
  };
}
