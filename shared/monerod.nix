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

    extraConfig =''
      p2p-bind-ip=127.0.0.1

      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050
      out-peers=16
      in-peers=32

      anonymous-inbound=$ONION_ANON

      hide-my-port=1
      no-igd=1
    '';
  };
}
