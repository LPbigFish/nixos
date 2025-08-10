{ pkgs, ... }:
{
  services.displayManager = {
    gdm = {
      enable = true;
      wayland = true;
    };
  };
  services.desktopManager.gnome.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };
}
