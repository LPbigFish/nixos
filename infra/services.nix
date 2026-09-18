{
  # Obsidian LiveSync endpoint.
  couchdb = {
    host = "orangepi5pro";
    web = {
      port = 5984;
      domain = "couchdb.lpbigfish.xyz";
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
}
