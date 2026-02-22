{
  config,
  pkgs,
  ...
}:
{
  services.httpd = {
    enable = true;
    enablePHP = true;
    virtualHosts."ucimse.rybak.website" = {
      listen = [ { ip = "0.0.0.0"; port = 8080; } ];
      documentRoot = "${config.services.moodle.package}/share/moodle/public";
      extraConfig = ''
        <Directory "${config.services.moodle.package}/share/moodle/public">
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
  };

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

    database = {
      type = "pgsql";
      name = "moodle";
      user = "moodle";
    };
    extraConfig = ''
      $CFG->reverseproxy = 1;
      $CFG->sslproxy = 1;
      $CFG->wwwroot = 'https://ucimse.rybak.website';
      $CFG->proxyadmins = '10.100.0.1';
    '';

    initialPassword = "1234567890";
  };
}
