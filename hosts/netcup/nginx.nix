{ ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
    25565
  ];

  networking.firewall.allowedUDPPorts = [ 24454 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "lpbigfish@proton.me";
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;

    virtualHosts = {
      "nextcloud.rybak.website" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.100.0.2:80";
          extraConfig = "client_max_body_size 10G;";
        };
      };
      "couchdb.rybak.website" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          # Forward to the Orange Pi WireGuard IP on Port 5984
          proxyPass = "http://10.100.0.2:5984";

          # Essential for LiveSync (Long polling)

          extraConfig = ''
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
            client_max_body_size 512M;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
    streamConfig = ''
      server {
        listen 25565;
        proxy_pass 10.100.0.2:25565;
        
        proxy_timeout 600s; 
        proxy_connect_timeout 30s;
      }

      # server {
      #   listen 24454 udp;
      #   proxy_pass 10.100.0.2:24454;
      # }
    '';
  };
}
