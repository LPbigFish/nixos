{ config, pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users = {
    root.hashedPasswordFile = config.sops.secrets.rootPassword.path;

    lpbigfish = {
      isNormalUser = true;
      description = "LPbigFish";
      extraGroups = [
        "networkmanager"
        "wheel"
        "adbusers"
      ];
      createHome = true;
      hashedPasswordFile = config.sops.secrets.lpbigfishPassword.path;
      shell = pkgs.zsh;
    };
  };

  users.defaultUserShell = pkgs.zsh;
}
