{
  inputs = {
    dedsec-grub-theme = {
      url = "gitlab:VandalByte/dedsec-grub-theme";
    };
  };

  outputs =
    {
      dedsec-grub-theme,
      ...
    }:
    {
      nixosModules.grubConfiguration =
        { ... }:
        {
          imports = [
            dedsec-grub-theme.nixosModule
          ];

          boot = {
            loader.efi.canTouchEfiVariables = true;

            # Use the GRUB 2 boot loader.
            loader.grub = {
              enable = true;
              efiSupport = true;
              device = "nodev";
              useOSProber = true;

              dedsec-theme = {
                enable = true;
                style = "comments";
                icon = "color";
                resolution = "1080p";
              };
            };
          };
        };
    };
}