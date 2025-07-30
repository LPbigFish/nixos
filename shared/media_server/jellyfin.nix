{ ... }: {
  users.users.jellyfin = {
    isNormalUser = true;
    description = "Jellyfin user account";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    createHome = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}