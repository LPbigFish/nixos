{ ... }: {
  services.monero = {
    enable = true;
    prune = true;

    rpc = {
      address = "127.0.0.1";
      restricted = true;
    };

    extraConfig = ''
      rpc-restricted-bind-port=18089
      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050
      out-peers=4
      limit-rate-up=20
    '';
  };
}