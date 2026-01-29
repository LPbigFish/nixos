{ config, lib, ... }:
let
  cfg = config.graphics-driver-selection;
in
lib.mkIf (cfg.gpu == "nvidia") {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;

    powerManagement.finegrained = false;

    open = false;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
}
