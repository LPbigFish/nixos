{
  description = "Dev shell toolkit";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAll =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          f pkgs
        );
    in
    {
      # Reusable dev shells
      devShells = forAll (pkgs: {
        rust = pkgs.mkShell {
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          packages = with pkgs; [
            cargo
            rustc
            rustfmt
            lldb
          ];
        };

        apps = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            gcc
            nasm
          ];
        };

        cuda = import ./cuda.nix { inherit pkgs; };
      });

      # Module that registers this flake as "devkit"
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
