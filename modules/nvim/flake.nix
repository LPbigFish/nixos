{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:NotAShelf/nvf";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nvf, flake-utils }:
    let
      systemOutputs = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          config = nvf.lib.neovimConfiguration {
            inherit pkgs;
            modules = [ ./nvf-configuration.nix ];
          };
        in
        {
          packages.default = config.neovim;
        }
      );
      overlay = final: prev: {
        my-neovim = (nvf.lib.neovimConfiguration {
          pkgs = final; 
          modules = [ ./nvf-configuration.nix ];
        }).neovim;
      };
    in
    systemOutputs // {
      overlays.default = overlay;
    };
}