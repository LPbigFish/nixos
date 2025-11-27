{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.graphics-driver-selection;
in
lib.mkIf (cfg.gpu == "intel") {

  services.xserver.videoDrivers = [ "intel" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

}