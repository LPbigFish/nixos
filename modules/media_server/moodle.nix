{
  config,
  pkgs,
  ...
}:
{
  # Nginx will be used to serve Moodle, avoiding conflicts with httpd.
  services.nginx.virtualHosts."ucimse.rybak.website" = {
    listen = [ { port = 8080; } ];
    root = "${config.services.moodle.package}/share/moodle/public";

    locations."/" = {
      index = "index.php";
      tryFiles = "$uri $uri/ /index.php?$args";
    };

    location."~ \.php$" = {
      extraConfig = ''
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include ${pkgs.nginx}/conf/fastcgi_params;
      '';
      fastcgi_param.SCRIPT_FILENAME = "$document_root$fastcgi_script_name";
      fastcgi_pass = "unix:${config.services.phpfpm.pools.moodle.socket}";
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
