{ config, ... }:
{
  sops.secrets.moneroEnv = {
    sopsFile = ../secrets/monero.env;
    format = "dotenv";
    owner = "monero";
    group = "monero";
    mode = "0400";
    restartUnits = [ "monero.service" ];
  };

  services.monero = {
    enable = true;
    prune = true;

    environmentFile = config.sops.secrets.moneroEnv.path;

    rpc = {
      address = "127.0.0.1";
      port = 18089;
      restricted = true;
    };

    mining = {
      enable = true;
      threads = 2;
      address = "8B4xALhnmhkWdwSKx7HYXVaK9B9WD44TAUHVgVbBziLY9rmJJNqWwX7JzwEqB93Ep6fZZwz1kL1SKCxKJ48xWfE8Tz1FfSY";
    };

    extraConfig =''
      p2p-bind-ip=127.0.0.1

      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050
      out-peers=16
      in-peers=32

      log-level=3

      anonymous-inbound=ibdfo3maxu2z7t5zlrfkd5i5bvz7vp5k2jir44b3l2ncpjtcs5x6knqd.onion:18084,127.0.0.1:18084,64

      hide-my-port=1
      no-igd=1
    '';
  };
}
