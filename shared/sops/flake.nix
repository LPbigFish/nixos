{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      ...
    }@inputs:
    {
      nixosModules.sops_configuration =
        { config, pkgs, ... }:
        {
          imports = [
            inputs.sops-nix.nixosModules.sops
          ];

          sops.defaultSopsFile = ../../secrets/secrets.yaml;
          sops.defaultSopsFormat = "yaml";

          sops.age.keyFile = "/home/lpbigfish/.config/sops/age/keys.txt";

          sops.age.generateKey = true;
        
          sops.secrets = {
            rootPassword = {};
            defaultUserPassword = {};
            wpaPassword = {};
          };
        };
    };
}
