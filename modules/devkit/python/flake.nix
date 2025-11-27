{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    poetry2nix.url = "github:nix-community/poetry2nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      poetry2nix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ poetry2nix.overlays.default ];
        };
        python = pkgs.python314;
        appDrv = pkgs.poetry2nix.mkPoetryApplication {
          inherit python;
          projectDir = ./.;
        };
        devEnv = pkgs.poetry2nix.mkPoetryEnv {
          inherit python;
          projectDir = ./.;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.poetry
            devEnv
          ];

          POETRY_VIRTUALENVS_IN_PROJECT = "true";
          POETRY_ENV_USE_SYSTEM = "true";

          shellHook = '''';
        };
      }
    );
}
