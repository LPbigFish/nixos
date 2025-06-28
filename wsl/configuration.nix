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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc.automatic = true;

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
    fulcrum
    electrum
    git
  ];

  users.users.lpbigfish.extraGroups = [ "docker" ];

  programs = {
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
    };
    direnv.enable = true;
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
