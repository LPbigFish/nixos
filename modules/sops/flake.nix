{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs =
    {
      ...
    }@inputs:
    {
      nixosModules.sops_configuration =
        {
          config,
          pkgs,
          ...
        }:
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

          services.openssh.hostKeys = [
            {
              path = "/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];

          sops = {
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";

            age = {
              sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              generateKey = false;
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
            };
          };

          fileSystems."/etc/ssh" = {
            device = "/nix/persist/etc/ssh";
            fsType = "none";
            options = [
              "bind"
              "X-mount.mkdir"
            ];
            neededForBoot = true;
          };
        };
    };
}
