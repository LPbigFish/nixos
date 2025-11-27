{ ... }:
{
  services.tor = {
    enable = true;

    client.enable = true;

    relay.onionServices = {
      monerod-p2p = {
        version = 3;
        path = "/var/lib/tor/onion/monerod-p2p";
        map = [
          {
            port = 18084;
            target = {
              addr = "127.0.0.1";
              port = 18084;
            };
          }
        ];
      };

      monerod-rpc = {
        version = 3;
        path = "/var/lib/tor/onion/monerod-rpc";
        map = [
          {
            port = 18089;
            target = {
              addr = "127.0.0.1";
              port = 18089;
            };
          }
          {
            port = 18081;
            target = {
              addr = "127.0.0.1";
              port = 18081;
            };
          }
        ];
      };
    };
  };
}
