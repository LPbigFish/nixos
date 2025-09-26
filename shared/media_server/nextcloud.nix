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

    config.adminuser = "lpbigfish";
    config.adminpassFile = config.sops.secrets.nextcloudAdminpass.path;

    settings = {
      "trusted_domains" = [ "nextcloud.rybak.website" ];
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

    config = {
      trusted_domains = [ "nextcloud.rybak.website" ];
      overwritehost = "nextcloud.rybak.website";
      overwriteprotocol = "https";
      overwrite.cli.url = "https://nextcloud.rybak.website";
      trustedProxies = [ "127.0.0.1" "::1" ];
    };

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

  services.cloudflared = {
    enable = true;
    tunnels."25b602b7-1da8-4039-a7ad-f51630ccfc12" = {
      credentialsFile = "/var/lib/cloudflared/tunnel.json";
      ingress = {
        "nextcloud.rybak.website" = "http://127.0.0.1:80";
      };
      default = "http_status:404";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
