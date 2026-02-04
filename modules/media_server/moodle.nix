{ config, lib, ... }:
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
        listen = [{ ip = "127.0.0.1"; port = 8080; }];
        documentRoot = lib.mkForce "${config.services.moodle.package}/share/moodle/public"; 
    };
    database = {
      type = "pgsql";
      name = "moodle";
      user = "moodle";
    };
    extraConfig = ''
      $CFG->reverseproxy = 1;
      $CFG->sslproxy = 0;
    '';

    initialPassword = "1234567890";
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "100m";

    virtualHosts."192.168.18.76" = {
      listen = [ { addr = "0.0.0.0"; port = 80; } ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
