{ pkgs, ... }:
{
  services.displayManager = {
    gdm = {
      enable = true;
      wayland = true;
    };
  };
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true; 

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
