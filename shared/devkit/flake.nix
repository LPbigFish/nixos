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
      };
    }
    // {

      nixosModules.registry =
        { ... }:
        {
          programs.adb.enable = true;

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.registry.devkit.flake = self;
        };
    };
}
