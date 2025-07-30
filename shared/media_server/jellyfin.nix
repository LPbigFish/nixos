{ ... }: {
  users.users.jellyfin = {
    isSystemUser = true;
    description = "Jellyfin user account";
    extraGroups = [
      "networkmanager"
    ];
    createHome = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}