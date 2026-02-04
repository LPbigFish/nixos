{
  config,
  lib,
  pkgs,
  ...
}:
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
    package = pkgs.moodle;

    virtualHost = {
      hostName = "192.168.18.76";
      listen = [
        {
          ip = "127.0.0.1";
          port = 8080;
        }
      ];
      documentRoot = lib.mkForce "${config.services.moodle.package}/share/moodle/public";

      # WIPE the module's Apache config and use this one
      extraConfig = lib.mkForce ''
        <Directory "${config.services.moodle.package}/share/moodle/public">
          <FilesMatch "\.php$">
            <If "-f %{REQUEST_FILENAME}">
              SetHandler "proxy:unix:${config.services.phpfpm.pools.moodle.socket}|fcgi://localhost/"
            </If>
          </FilesMatch>
          Options -Indexes +FollowSymLinks
          AllowOverride All
          Require all granted
          DirectoryIndex index.php
        </Directory>

        # We must ALSO allow access to the parent dir because Moodle 
        # internally references files there (like config.php)
        <Directory "${config.services.moodle.package}/share/moodle">
            Require all granted
        </Directory>
      '';
    };
    database = {
      type = "pgsql";
      name = "moodle";
      user = "moodle";
    };
    extraConfig = ''
      $CFG->reverseproxy = 0;
      $CFG->sslproxy = 0;
      $CFG->wwwroot = 'http://192.168.18.76';
      $CFG->routerconfigured = true;
      $CFG->proxyadmins = '127.0.0.1';
    '';

    initialPassword = "1234567890";
  };

  services.nginx = {
    enable = true;
    virtualHosts."_" = {
      # Use wildcard to catch all requests on port 80
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080/";
        extraConfig = ''
          proxy_set_header Host 192.168.18.76; # Hardcode it to match wwwroot exactly
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host 192.168.18.76;
        '';
      };
    };
  };
}
