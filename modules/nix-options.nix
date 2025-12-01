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

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };
}
