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
    '';
  };
}
