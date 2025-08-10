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
    add-to-desktop
    emoji-copy
    lockscreen-extension
    customize-clock-on-lock-screen
    appindicator
    gtile
    bluetooth-quick-connect
    hide-top-bar
  ];

  extensionUuidList = builtins.map (x: x.extensionUuid) extensions;
in
{
  inherit extensions extensionUuidList;
}