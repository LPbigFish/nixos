{ pkgs, config, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;

    hostName = "rybak.website";

    config.adminpassFile = config.sops.secrets.nextcloudAdminpass.path;

    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      dbpassFile = config.sops.secrets.nextcloudAdminpass.path;
    };

    https = true;

    settings = {
      "trusted_domains" = [ "rybak.website" ];
      "trusted_proxies" = [ "10.10.0.1" ];
      "overwrite.cli.url" = "https://rybak.website/nextcloud";
      "overwritehost" = "rybak.website";
      "overwriteprotocol" = "https";
      "overwritewebroot" = "/nextcloud";
      "htaccess.RewriteBase" = "/nextcloud";
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

  services.redis.enable = true;

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    clientMaxBodySize = "2G";
    virtualHosts."nextcloud-internal" = {
      forceSSL = false;
      listen = [
        { addr = "10.10.0.2"; port = 8080; ssl = false; }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ ];
    interfaces.wg0.allowedTCPPorts = [ 8080 ];
  };
}
