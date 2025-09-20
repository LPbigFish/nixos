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
      address = "0.0.0.0";
      port = 18089;
      user = "$RPC_USER";
      password = "$RPC_PASS";
    };

    mining = {
      enable = true;
      address = "$MINING_ADDRESS";
      threads = 2;
    };

    extraConfig = ''
      p2p-bind-ip=127.0.0.1

      confirm-external-bind=1

      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050
      out-peers=16
      in-peers=32

      log-level=1

      anonymous-inbound=$ONION_ANON

      hide-my-port=1
      no-igd=1
    '';
  };

  networking.firewall.interfaces.enP4p65s0.allowedTCPPorts = [ 18089 ];
}
