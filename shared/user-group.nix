{ config, ... }:
{

  users.users = {
    root.hashedPasswordFile = config.sops.secrets.rootPassword.path;

    lpbigfish = {
      isNormalUser = true;
      description = "LPbigFish";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      createHome = true;
      hashedPasswordFile = config.sops.secrets.lpbigfishPassword.path;
    };
  };

}
