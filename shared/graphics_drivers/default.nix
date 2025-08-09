{ lib, config, ... }:

{
  # the public selector
  options.graphics-driver-selection.gpu = lib.mkOption {
    type        = lib.types.enum [ "intel" "nvidia" "amd" "none" ];
    default     = "none";
    description = "Choose which discrete GPU stack should be enabled.";
  };

  # NOTE: nothing dynamic here – just list the files
  imports = [
    ./intel.nix
    ./nvidia.nix
    ./amd.nix
  ];
}