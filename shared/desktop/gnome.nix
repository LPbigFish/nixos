{ ... }: {
  services.displayManager = {
    gdm = {
      enable = true;  
      wayland = true; 
    };
  };
  services.desktopManager.gnome.enable = true;
}