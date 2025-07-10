# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  wsl.enable = true;
  wsl.defaultUser = "lpbigfish";

  graphics-driver-selection.gpu = "none";

  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    nixfmt-rfc-style
    nil
    dbeaver-bin
    docker-compose
    git
  ];

  users.users.lpbigfish.extraGroups = [ "docker" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
