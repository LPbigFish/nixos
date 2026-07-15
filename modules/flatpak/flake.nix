{
  description = "Flatpak module";

  inputs = {
    nixpkgs-flatpak.url = "github:NixOS/nixpkgs/51effaf9783e0226281ad10e95a4af6c8a145316";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    { nix-flatpak, nixpkgs-flatpak, ... }:
    {
      nixosModules.flatpak =
        { pkgs, ... }:
        {
          imports = [
            nix-flatpak.nixosModules.nix-flatpak
          ];

          xdg.portal.enable = true;

          services.flatpak = {
            enable = true;
            update.onActivation = true;
            package = nixpkgs-flatpak.legacyPackages.${pkgs.system}.flatpak;

            packages = [
              "org.vinegarhq.Sober"
              "com.stremio.Stremio"
              "org.vinegarhq.Vinegar"
            ];
          };
        };
    };
}
