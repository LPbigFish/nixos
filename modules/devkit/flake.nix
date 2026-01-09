{
  description = "Dev toolkit";

  outputs =
    {
      self,
      ...
    }: {
      templates = {
        rust = {
          path = ./rust;
          description = "Rust dev template";
        };
        
        android = {
          path = ./android;
          description = "Android dev template";
        };

        node = {
          path = ./node;
          description = "NodeJS dev template";
        };
        python = {
          path = ./python;
          description = "Python dev template";
        };
      };
    }
    // {

      nixosModules.registry =
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.android-tools ];
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.registry.devkit.flake = self;
        };
    };
}
