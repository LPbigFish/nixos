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
      };
    }
    // {

      nixosModules.registry =
        { ... }:
        {
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.registry.devkit.flake = self;
        };
    };
}
