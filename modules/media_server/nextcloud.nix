{ pkgs, config, ... }:
{
  sops.secrets.nextcloudAdminpass = {
    sopsFile = ../../secrets/nextcloud.yaml;
    owner = config.users.users.nextcloud.name;
  };

  sops.secrets.nextcloud-email-config = {
    sopsFile = ../../secrets/nextcloud.yaml;
    owner = config.users.users.nextcloud.name;
    group = config.users.users.nextcloud.group; # Important for permissions
    restartUnits = [ "php-fpm-nextcloud.service" ]; # Auto-restart on change
  };

  # sops.secrets."tunnel.json" = {
  # sopsFile = ../../secrets/tunnel.yaml;
  # path = "/var/lib/cloudflared/tunnel.json";
  #};

  services.nextcloud = {
    enable = true;

    package = pkgs.nextcloud32;

    secretFile = config.sops.secrets.nextcloud-email-config.path;

    hostName = "nextcloud.rybak.website";

    config.adminuser = "lpbigfish";
    config.adminpassFile = "${config.sops.secrets.nextcloudAdminpass.path}";

    settings = {
      "trusted_domains" = [ "nextcloud.rybak.website" ];
      overwriteprotocol = "https";
      trusted_proxies = [
        "10.100.0.1"
        "127.0.0.1"
        "::1"
      ];
      overwritehost = "nextcloud.rybak.website";
      "overwrite.cli.url" = "https://nextcloud.rybak.website";
      "overwritewebroot" = "\/";
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
      inherit (pkgs.nextcloud32.packages.apps)
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

  services.nginx.enable = true;
  #  services.cloudflared = {
  #    enable = true;
  #    tunnels."25b602b7-1da8-4039-a7ad-f51630ccfc12" = {
  #      credentialsFile = "/var/lib/cloudflared/tunnel.json";
  #      ingress = {
  #        "nextcloud.rybak.website" = "http://127.0.0.1:80";
  #      };
  #      default = "http_status:404";
  #    };
  #  };
}
