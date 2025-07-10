{ pkgs, config, lib, ... }:
let
  cfg = config.graphics-driver-selection;
in
lib.mkIf (cfg.gpu == "amd") {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ amdvlk ];
  };
}