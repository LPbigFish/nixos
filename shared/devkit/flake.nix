{
  description = "Dev shell toolkit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    #rust-dev = {
    #  url = ./rust-flake.nix;
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:

      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.rust-overlay.overlays.default ];
        };
      in
      {
        devShells = {
          rust = import ./rust.nix { inherit pkgs; };

          apps = pkgs.mkShell {
            packages = with pkgs; [
              cmake
              gcc
              nasm
            ];
          };

          cuda = import ./cuda.nix { inherit pkgs; };
        };
      }
    )
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
