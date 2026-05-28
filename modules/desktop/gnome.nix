{ pkgs, ... }:
{
  services.displayManager = {
    gdm = {
      enable = true;
    };
  };
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
