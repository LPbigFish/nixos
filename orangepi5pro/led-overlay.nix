{
  hardware.deviceTree.overlays = [
    {
      name = "opi5pro-no-leds";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
            compatible = "rockchip,rk3588s-orangepi-5-pro";
        };
        / {
            fragment@0 {
                target-path = "/gpio-leds/blue_led@1";
                __overlay__ {
                    linux,default-trigger = "none";
                    default-state = "off";
                };
            };

            fragment@1 {
                target-path = "/gpio-leds/green_led@2";
                __overlay__ {
                    linux,default-trigger = "none";
                    default-state = "off";
                };
            };
        };
      '';
    }
  ];
}