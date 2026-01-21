{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "moodle" ];
    ensureUsers = [
      {
        name = "moodle";
        ensureDBOwnership = true;
      }
    ];
  };

  services.moodle = {
    enable = true;
    virtualHost = {
        hostName = "192.168.18.76";
    };
    database = {
      type = "pgsql";
      name = "moodle";
      user = "moodle";
    };

    # initialPassword = "1234567890";
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "100m";

    virtualHosts."192.168.18.76" = {
      listen = [ { addr = "0.0.0.0"; port = 80; } ];
    };
  };
}