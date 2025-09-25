{ pkgs, config, ... }:
{
  sops.secrets.nextcloudAdminpass = {
    sopsFile = ../../secrets/nextcloud.yaml;
    owner = config.users.users.nextcloud.name;
  };

  sops.secrets."tunnel.json" = {
    sopsFile = ../../secrets/tunnel.yaml;
    path = "/var/lib/cloudflared/tunnel.json";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;

    hostName = "nextcloud.rybak.website";

    https = true;

    config.adminuser = "lpbigfish";
    config.adminpassFile = config.sops.secrets.nextcloudAdminpass.path;

    settings = {
      "trusted_domains" = [ "rybak.website" ];
    };

    maxUploadSize = "2G";
    settings.enabledPreviewProviders = [
      "OC\\Preview\\BMP"
      "OC\\Preview\\GIF"
      "OC\\Preview\\JPEG"
      "OC\\Preview\\PNG"
      "OC\\Preview\\TXT"
      "OC\\Preview\\XBitmap"
      "OC\\Preview\\HEIC"
    ];

    config.dbtype = "sqlite";

    configureRedis = true;

    extraAppsEnable = true;
    extraApps = {
      inherit (pkgs.nextcloud31.packages.apps)
        calendar
        cospend
        deck
        end_to_end_encryption
        files_automatedtagging
        impersonate
        notes
        phonetrack
        registration
        ;
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };

  security.acme = {
    acceptTerms = true;
    certs = { 
      ${config.services.nextcloud.hostName}.email = "lpbyblock@gmail.com";
    }; 
  };

  services.cloudflared = {
    enable = true;
    tunnels."25b602b7-1da8-4039-a7ad-f51630ccfc12" = {
      credentialsFile = "/var/lib/cloudflared/tunnel.json";
      ingress = {
        "nextcloud.rybak.website" = "https://127.0.0.1:443";
      };
      default = "http_status:404";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
