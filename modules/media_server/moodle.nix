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

    virtualHost.hostName = "moodle-dummy.local";

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

  services.httpd.virtualHosts."192.168.18.76" = {
    # Point explicitly to the public directory
    documentRoot = "${config.services.moodle.package}/share/moodle/public";

    extraConfig = ''
      <Directory "${config.services.moodle.package}/share/moodle/public">
        # Connect to the PHP-FPM socket created by the moodle service
        <FilesMatch "\.php$">
          <If "-f %{REQUEST_FILENAME}">
            SetHandler "proxy:unix:${config.services.phpfpm.pools.moodle.socket}|fcgi://localhost/"
          </If>
        </FilesMatch>
        
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
      </Directory>
    '';
  };
}
