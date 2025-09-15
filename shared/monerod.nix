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
      # Tor-only
      proxy=127.0.0.1:9050
      tx-proxy=tor,127.0.0.1:9050,enable_noise=1
      out-peers=64

      # Make the local P2P listener match your anonymous-inbound target
      p2p-bind-ip=127.0.0.1
      p2p-bind-port=18080
      hide-my-port=1

      # Tor hidden service that forwards to the local listener above
      anonymous-inbound=127.0.0.1:18080,127.0.0.1:9050
    '';
  };
}
