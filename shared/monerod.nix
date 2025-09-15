{ ... }:
{
  services.monero = {
    enable = true;
    prune = true;

    rpc = {
      address = "127.0.0.1";
      restricted = true;
    };

    extraConfig = ''
      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050,enable_noise=1
      out-peers=64

      p2p-bind-ip=127.0.0.1
      p2p-bind-port=18090
      hide-my-port=1

      tor-control=127.0.0.1:9051

      anonymous-inbound=127.0.0.1:18090,127.0.0.1:9050
    '';
  };
}
