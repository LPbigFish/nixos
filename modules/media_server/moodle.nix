{
  config,
  pkgs,
  ...
}:
{
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
    enable = false;
    package = pkgs.moodle;
    virtualHost.hostName = "ucimse.rybak.website";

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
