{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    
    package = pkgs.postgresql_17; 

    settings = {
      listen_addresses = "*";
    };

    ensureUsers = [
      {
        name = "handy_java";
        ensureClauses = {
          createdb = true;
          login = true;
        };
      }
    ];

    authentication = pkgs.lib.mkOverride 10 ''
      # Type  Database    User        Address            Method
      local   all         all                            trust
      host    all         all         127.0.0.1/32       trust
      host    all         all         ::1/128            trust
      
      # Allow access from your local network
      host    all         all         192.168.18.0/24    scram-sha-256
    '';
  };
}
