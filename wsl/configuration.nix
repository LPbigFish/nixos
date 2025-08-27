# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  pkgs,
  ...
}:
{
  wsl.enable = true;
  wsl.defaultUser = "lpbigfish";

  graphics-driver-selection.gpu = "nvidia";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      "default-runtime" = "nvidia";
      "runtimes" = {
        "nvidia" = {
          "path" = "/run/current-system/sw/bin/nvidia-container-runtime";
          "args" = [];
        };
      };
    };
  };

  systemd.services.docker.environment.LD_LIBRARY_PATH = "/usr/lib/wsl/lib";

  environment.systemPackages = with pkgs; [
    dbeaver-bin
    docker-compose
  ];

  users.users.lpbigfish.extraGroups = [ "docker" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
