{
  inputs = {
    dedsec-grub-theme = {
      url = "gitlab:VandalByte/dedsec-grub-theme";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      dedsec-grub-theme,
      ...
    }:
    {
      nixosModules.grubConfiguration =
        { config, dedsec-grub-theme, ... }:
        {
          boot = {
            loader.efi.canTouchEfiVariables = true;

            # Use the GRUB 2 boot loader.
            loader.grub = {
              enable = true;
              version = 2;
              efiSupport = true;
              device = "nodev";
              useOSProber = true;

              dedsec-theme = {
                enable = true;
                style = "sitedown";
                icon = "color";
                resolution = "1080p";
              };
            };
          };
        };
    };
}
