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

          environment.systemPackages = with pkgs; [
            sops
            ssh-to-age
            ssh-to-pgp
            age
            gnupg
          ];

          sops = {
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";

            age = {
              sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              keyFile = "/nix/persist/var/lib/sops-nix/key.txt";
              generateKey = true;
            };

            secrets = {
              lpbigfishPassword = {
                owner = config.users.users.lpbigfish.name;
                neededForUsers = true;
              };
              rootPassword = {
                owner = config.users.users.root.name;
                neededForUsers = true;
              };
              wpaPassword = { };

              nextcloudAdminpass = {
                sopsFile = ../../secrets/nextcloud.yaml;
              };
            };
          };

          environment.variables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
        };
    };
}
