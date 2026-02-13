{ config, pkgs, ... }:
{
  sops.secrets.couchConfigFile = {
    sopsFile = ../../secrets/couchdb.yaml;
    owner = config.users.users.couchdb.name;
  };

  networking.firewall.allowedTCPPorts = [ 5984 ];

  services.couchdb = {
    enable = true;
    bindAddress = "0.0.0.0";

    configFile = config.sops.secrets.couchConfigFile.path;
  };
}
