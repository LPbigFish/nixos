{
  hardware.deviceTree.overlays = [
    {
      name = "opi5pro-no-leds";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        // Turn off blue_led@1
        fragment@0 {
          target-path = "/gpio-leds/blue_led@1";
          __overlay__ {
            linux,default-trigger = "none";
            default-state = "off";
          };
        };

        // Turn off green_led@2
        fragment@1 {
          target-path = "/gpio-leds/green_led@2";
          __overlay__ {
            linux,default-trigger = "none";
            default-state = "off";
          };
        };
      '';
    }
  ];
}