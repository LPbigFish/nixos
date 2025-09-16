{ ... }:
{
  services.monero = {
    enable = true;
    prune = true;

    rpc = {
      address = "127.0.0.1";
      port = 18089;
      restricted = true;
    };

    extraConfig = ''
      p2p-bind-ip=127.0.0.1

      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050,disable_noise
      #out-peers=16

      anonymous-inbound=tqexzzd7uxikxjzvmag7vbbj7x3xkt4litzjkywmi4us25du3ie32zad.onion:18084,127.0.0.1:18084,64

      hide-my-port=1
      no-igd=1

      log-level=2
    '';
  };
}
