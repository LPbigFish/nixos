{ pkgs }: let
  extensions = with pkgs.gnomeExtensions; [
    caffeine
    blur-my-shell
    dash-to-dock
    clipboard-indicator
    user-themes
    gsconnect
    wifi-qrcode
    status-area-horizontal-spacing
    quick-settings-tweaker
    sound-output-device-chooser
    add-to-desktop
    emoji-copy
    wintile-beyond
    lockscreen-extension
    customize-clock-on-lock-screen
  ];

  uuidExtensions = builtins.map (x: x.extensionUuid) extensions;
in
{
  inherit extensions;
  extensionUuidList = uuidExtensions;
}