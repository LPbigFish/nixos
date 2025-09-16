{ ... }:
{
  services.tor = {
    enable = true;

    client.enable = true;

    relay.onionServices.monerod-rpc = {
      version = 3;
      path = "/var/lib/tor/onion/monerod-rpc";
      map = [
        {
          # Monerod
          port = 18089;
          target = {
            addr = "127.0.0.1";
            port = 18089;
          };
        }
      ];
    };
  };
}
