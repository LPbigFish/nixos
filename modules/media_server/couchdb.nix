{ config, pkgs, ... }:
{
  sops.secrets.couchConfigFile = {
    sopsFile = ../../secrets/couchdb.yaml;
    owner = config.users.users.couchdb.name;
  };

  # port 5984 is opened on wg0 by modules/infrastructure/service-firewall.nix

  services.couchdb = {
    enable = true;
    bindAddress = "0.0.0.0";

    configFile = config.sops.secrets.couchConfigFile.path;
  };
}
