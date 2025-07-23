{ ... }: {
  services.displayManager = {
    gdm = {
      enable = true;  
      wayland = true; 
    };
    gnome.enable = true;
  };
}