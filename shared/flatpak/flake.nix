{
  description = "Flatpak module";

  inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = { self, nix-flatpak, ... }: {
    nixosModules.flatpak = { config, pkgs, ...}: {
      imports = [
        nix-flatpak.nixosModules.nix-flatpak
      ];

      xdg.portal.enable = true;

      services.flatpak = {
        enable = true;
        update.onActivation = true;
        packages = [
          "org.vinegarhq.Sober"
        ];
      };
    };
  };
}