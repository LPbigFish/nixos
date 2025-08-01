{ pkgs, ... }:
let
  ffmpeg-rk = pkgs.jellyfin-ffmpeg.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [
      "--enable-rkmpp"
    ];
  });
in
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
    ffmpeg-rk

    pkgs.jellyfin
    pkgs.jellyfin-web
  ];
}
