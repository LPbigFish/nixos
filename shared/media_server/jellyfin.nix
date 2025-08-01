{ pkgs, ... }:
{
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin.path = [ pkgs.jellyfin-ffmpeg ];

  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = [
    pkgs.v4l-utils

    pkgs.jellyfin
    pkgs.jellyfin-web
  ];
}
