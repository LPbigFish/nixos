{
  description = "Flatpak module";

  inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    { nix-flatpak, ... }:
    {
      nixosModules.flatpak =
        { ... }:
        {
          imports = [
            nix-flatpak.nixosModules.nix-flatpak
          ];

          xdg.portal.enable = true;

          services.flatpak = {
            enable = true;
            update.onActivation = true;

            remotes = [
              {
                name = "flathub";
                location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
              }
            ];

            packages = [
              "org.vinegarhq.Sober"
              "com.stremio.Stremio"
              "org.freecad.FreeCAD"
            ];
          };
        };
    };
}
