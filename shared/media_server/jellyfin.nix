{ pkgs, ... }: {
  hardware.opengl.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [ "video" "render" ];

  environment.systemPackages = with pkgs; [ v4l-utils ffmpeg ];
}