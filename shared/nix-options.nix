{ pkgs, ... }:
{
  security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      package = pkgs.sudo-rs;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
  };

  #nixpkgs.config = {
  #  allowUnfree = true;
  #};

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };

    gc = {
      automatic = true;
      options = "-d --keep 2";
      dates = "03:15";
    };
  };
}
