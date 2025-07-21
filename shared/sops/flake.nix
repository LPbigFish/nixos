{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs = { self, nixpkgs, sops-nix }: {
    nixosModules.sops_configuration = { config, pkgs, ... }: {

    };
  };
}