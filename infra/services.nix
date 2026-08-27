{
  nextcloud = {
    host = "orangepi5pro";
    web = {
      port = 80;
      domain = "nextcloud.rybak.website";
      proxyExtraConfig = "client_max_body_size 10G;";
    };
  };

  couchdb = {
    host = "orangepi5pro";
    web = {
      port = 5984;
      domain = "couchdb.rybak.website";
      # Essential for LiveSync (long polling)
      proxyExtraConfig = ''
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
        client_max_body_size 512M;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  minecraft = {
    host = "orangepi5pro";
    tcp = {
      port = 25565;
      publicPort = 25565;
    };
    # Voice-chat port: opened on the gateway firewall but not forwarded
    # (previous config had the udp stream block commented out).
    udp = {
      port = 24454;
      publicPort = 24454;
      proxy = false;
    };
  };
}
