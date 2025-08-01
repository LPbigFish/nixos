{ pkgs, ... }: 
let 
  ffmpeg-rk = pkgs.jellyfin-ffmpeg.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [ "--enable-rkmpp" "--enable-rga" ];
  });
in{
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    ffmpegPackage = ffmpeg-rk;
  };

  users.users.jellyfin.extraGroups = [ "video" "render" ];

  environment.systemPackages = with pkgs; [ v4l-utils ];
}