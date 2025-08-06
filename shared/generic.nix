{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./nix-options.nix
    ./graphics_drivers
  ];

  programs = {
    nh = {
      enable = true;
      flake = "/home/lpbigfish/.config/nixos";
    };
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
    };
    direnv.enable = true;
  };

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];

  environment.systemPackages = lib.mkBefore (with pkgs; [
    nano
    vim
    btop
    nixd
    nixfmt-rfc-style
    git
  ]);
}
