{ ... }:
{
  services.tor = {
    enable = true;

    client.enable = true;

    settings = {
      SocksPort = 9050;
      ControlPort = 9051;
      CookieAuthentication = true;
      CookieAuthFileGroupReadable = true;
    };

    /* relay.onionServices.monerod-rpc = {
      version = 3;
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
    }; */
  };
}
