{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "com/usebottles/bottles" = {
      show-sandbox-warning = false;
      startup-view = "page_list";
      window-height = 640;
      window-width = 880;
    };

    "org/gnome/Console" = {
      custom-font = "MesloLGL Nerd Font Mono 12";
      font-scale = mkDouble "0.7";
      last-window-maximised = false;
      last-window-size = mkTuple [ 732 528 ];
      use-system-font = false;
    };

    "org/gnome/Loupe" = {
      show-properties = true;
    };

    "org/gnome/Music" = {
      window-maximized = true;
    };

    "org/gnome/calculator" = {
      base = 10;
      button-mode = "basic";
      source-units = [ "degree" ];
      target-units = [ "radian" ];
      unit-category = "angle";
      window-maximized = false;
      window-size = mkTuple [ 375 616 ];
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-size = mkTuple [ 768 600 ];
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "world";
      size = mkTuple [ 868 690 ];
    };

    "org/gnome/control-center" = {
      last-panel = "keyboard";
      window-state = mkTuple [ 980 640 false ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "System" "Utilities" "YaST" "Pardus" ];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/System" = {
      apps = [ "org.gnome.baobab.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Logs.desktop" "org.gnome.tweaks.desktop" "org.gnome.SystemMonitor.desktop" ];
      name = "X-GNOME-Shell-System.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "org.gnome.Decibels.desktop" "org.gnome.Connections.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" ];
      name = "X-GNOME-Shell-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = true;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = mkUint32 300;
      interval-seconds = mkUint32 1800;
      play-sound = true;
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "cz" ]) ];
      per-window = false;
      sources = [ (mkTuple [ "xkb" "cz" ]) (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      accent-color = "blue";
      color-scheme = "prefer-dark";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-enable-primary-paste = false;
      icon-theme = "Papirus";
      monospace-font-name = "MesloLGL Nerd Font Mono 11";
      show-battery-percentage = true;
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-software" "gnome-power-panel" "org-gnome-console" "discord" ];
    };

    "org/gnome/desktop/notifications/application/brave-browser" = {
      application-id = "brave-browser.desktop";
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/com-usebottles-bottles" = {
      application-id = "com.usebottles.bottles.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-about-panel" = {
      application-id = "gnome-about-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/idea" = {
      application-id = "idea.desktop";
    };

    "org/gnome/desktop/notifications/application/lunarclient" = {
      application-id = "lunarclient.desktop";
    };

    "org/gnome/desktop/notifications/application/mullvad-vpn" = {
      application-id = "mullvad-vpn.desktop";
    };

    "org/gnome/desktop/notifications/application/org-freecad-freecad" = {
      application-id = "org.freecad.FreeCAD.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-baobab" = {
      application-id = "org.gnome.baobab.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-epiphany" = {
      application-id = "org.gnome.Epiphany.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    "org/gnome/desktop/notifications/application/pycharm" = {
      application-id = "pycharm.desktop";
    };

    "org/gnome/desktop/notifications/application/steam" = {
      application-id = "steam.desktop";
    };

    "org/gnome/desktop/notifications/application/tidal-hifi" = {
      application-id = "tidal-hifi.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = mkDouble "0.304721";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Settings.desktop" "org.gnome.Contacts.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/wm/keybindings" = {
      maximize = [];
      unmaximize = [];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
    };

    "org/gnome/epiphany/state" = {
      is-maximized = false;
      window-size = mkTuple [ 1024 768 ];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 67;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/mutter" = {
      edge-tiling = false;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
      initial-size-file-chooser = mkTuple [ 890 550 ];
      maximized = false;
    };

    "org/gnome/nm-applet/eap/8b7d8a56-e566-4625-8d07-4ea71759c0a5" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/b9f901a1-e8c2-337e-b7fa-7b1478516073" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/d5eea15e-1201-4c00-959b-df4ebc971a7f" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/papers" = {
      night-mode = false;
    };

    "org/gnome/papers/default" = {
      annot-color = "yellow";
      continuous = true;
      dual-page = false;
      dual-page-odd-left = false;
      enable-spellchecking = true;
      show-sidebar = true;
      sizing-mode = "automatic";
      window-height = 1440;
      window-width = 1720;
    };

    "org/gnome/portal/filechooser/brave-browser" = {
      last-folder-path = "/home/lpbigfish/Downloads";
    };

    "org/gnome/portal/filechooser/discord" = {
      last-folder-path = "/home/lpbigfish/Downloads";
    };

    "org/gnome/portal/filechooser/org/chromium/Chromium" = {
      last-folder-path = "/home/lpbigfish/Downloads";
    };

    "org/gnome/settings-daemon/peripherals/keyboard" = {
      numlock-state = "on";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = false;
      night-light-schedule-automatic = false;
    };

    "org/gnome/settings-daemon/plugins/housekeeping" = {
      donation-reminder-last-shown = mkInt64 1765887551016020;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      help = [];
      www = [ "<Super>b" ];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      app-picker-layout = [ [
        (mkDictionaryEntry ["org.gnome.Geary.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 0)])
        ])])
        (mkDictionaryEntry ["org.gnome.Contacts.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 1)])
        ])])
        (mkDictionaryEntry ["org.gnome.Weather.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 2)])
        ])])
        (mkDictionaryEntry ["org.gnome.clocks.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 3)])
        ])])
        (mkDictionaryEntry ["org.gnome.Maps.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 4)])
        ])])
        (mkDictionaryEntry ["org.gnome.Music.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 5)])
        ])])
        (mkDictionaryEntry ["org.gnome.SimpleScan.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 6)])
        ])])
        (mkDictionaryEntry ["org.gnome.Settings.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 7)])
        ])])
        (mkDictionaryEntry ["org.gnome.Showtime.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 8)])
        ])])
        (mkDictionaryEntry ["org.gnome.Snapshot.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 9)])
        ])])
        (mkDictionaryEntry ["org.gnome.Characters.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 10)])
        ])])
        (mkDictionaryEntry ["android-studio.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 11)])
        ])])
        (mkDictionaryEntry ["Utilities" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 12)])
        ])])
        (mkDictionaryEntry ["System" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 13)])
        ])])
        (mkDictionaryEntry ["com.usebottles.bottles.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 14)])
        ])])
        (mkDictionaryEntry ["org.gnome.Tour.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 15)])
        ])])
        (mkDictionaryEntry ["org.gnome.Yelp.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 16)])
        ])])
        (mkDictionaryEntry ["btop.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 17)])
        ])])
        (mkDictionaryEntry ["org.gnome.Calculator.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 18)])
        ])])
        (mkDictionaryEntry ["clion.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 19)])
        ])])
        (mkDictionaryEntry ["datagrip.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 20)])
        ])])
        (mkDictionaryEntry ["davinci-resolve.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 21)])
        ])])
        (mkDictionaryEntry ["discord.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 22)])
        ])])
        (mkDictionaryEntry ["org.gnome.Extensions.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 23)])
        ])])
      ] [
        (mkDictionaryEntry ["com.heroicgameslauncher.hgl.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 0)])
        ])])
        (mkDictionaryEntry ["idea-ultimate.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 1)])
        ])])
        (mkDictionaryEntry ["startcenter.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 2)])
        ])])
        (mkDictionaryEntry ["base.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 3)])
        ])])
        (mkDictionaryEntry ["calc.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 4)])
        ])])
        (mkDictionaryEntry ["draw.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 5)])
        ])])
        (mkDictionaryEntry ["impress.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 6)])
        ])])
        (mkDictionaryEntry ["math.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 7)])
        ])])
        (mkDictionaryEntry ["writer.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 8)])
        ])])
        (mkDictionaryEntry ["net.lutris.Lutris.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 9)])
        ])])
        (mkDictionaryEntry ["cups.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 10)])
        ])])
        (mkDictionaryEntry ["mullvad-vpn.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 11)])
        ])])
        (mkDictionaryEntry ["nvim.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 12)])
        ])])
        (mkDictionaryEntry ["nixos-manual.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 13)])
        ])])
        (mkDictionaryEntry ["nvidia-settings.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 14)])
        ])])
        (mkDictionaryEntry ["protontricks.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 15)])
        ])])
        (mkDictionaryEntry ["pycharm-professional.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 16)])
        ])])
        (mkDictionaryEntry ["rider.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 17)])
        ])])
        (mkDictionaryEntry ["scrcpy.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 18)])
        ])])
        (mkDictionaryEntry ["scrcpy-console.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 19)])
        ])])
        (mkDictionaryEntry ["org.vinegarhq.Sober.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 20)])
        ])])
        (mkDictionaryEntry ["org.gnome.Software.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 21)])
        ])])
        (mkDictionaryEntry ["steam.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 22)])
        ])])
        (mkDictionaryEntry ["org.gnome.Calendar.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 23)])
        ])])
      ] [
        (mkDictionaryEntry ["org.gnome.TextEditor.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 0)])
        ])])
        (mkDictionaryEntry ["vim.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 1)])
        ])])
        (mkDictionaryEntry ["org.gnome.Papers.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 2)])
        ])])
        (mkDictionaryEntry ["org.gnome.Nautilus.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 3)])
        ])])
        (mkDictionaryEntry ["org.gnome.Epiphany.desktop" (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant 4)])
        ])])
      ] ];
      disable-user-extensions = false;
      disabled-extensions = [ "wintile-beyond@GrylledCheez.xyz" ];
      enabled-extensions = [ "caffeine@patapon.info" "blur-my-shell@aunetx" "dash-to-dock@micxgx.gmail.com" "clipboard-indicator@tudmotu.com" "user-theme@gnome-shell-extensions.gcampax.github.com" "gsconnect@andyholmes.github.io" "add-to-desktop@tommimon.github.com" "emoji-copy@felipeftn" "lockscreen-extension@pratap.fastmail.fm" "CustomizeClockOnLockScreen@pratap.fastmail.fm" "appindicatorsupport@rgcjonas.gmail.com" "bluetooth-quick-connect@bjarosze.gmail.com" "hidetopbar@mathieu.bidon.ca" "tiling-assistant@leleat-on-github" ];
      favorite-apps = [ "Alacritty.desktop" "brave-browser.desktop" "code.desktop" ];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "48.3";
    };

    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = mkDouble "0.0";
      icon-contrast = mkDouble "0.0";
      icon-opacity = 240;
      icon-saturation = mkDouble "2.7755575615628914e-17";
      icon-size = 18;
      legacy-tray-enabled = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = mkDouble "0.6";
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = mkDouble "0.6";
      pipeline = "pipeline_default_rounded";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness = mkDouble "0.6";
      pipeline = "pipeline_default";
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = mkDouble "0.6";
      sigma = 30;
    };

    "org/gnome/shell/extensions/caffeine" = {
      cli-toggle = false;
      indicator-position-max = 1;
      user-enabled = true;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      display-mode = 0;
      paste-on-select = false;
    };

    "org/gnome/shell/extensions/custom-accent-colors" = {
      accent-color = "orange";
    };

    "org/gnome/shell/extensions/customize-clock-on-lockscreen" = {
      command-output-font-color = "rgba(255, 255, 255, 1)";
      command-output-font-size = 58;
      date-font-color = "rgba(255, 255, 255, 1)";
      hint-font-color = "rgba(255, 255, 255, 1)";
      remove-command-output = true;
      remove-date = false;
      time-font-color = "rgba(255, 255, 255, 1)";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = true;
      apply-custom-theme = true;
      background-opacity = mkDouble "0.0";
      custom-background-color = false;
      custom-theme-shrink = true;
      dash-max-icon-size = 40;
      disable-overview-on-startup = false;
      dock-position = "BOTTOM";
      extend-height = false;
      height-fraction = mkDouble "0.9";
      icon-size-fixed = false;
      isolate-monitors = false;
      isolate-workspaces = false;
      multi-monitor = false;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "eDP-1";
      preview-size-scale = mkDouble "0.0";
      running-indicator-style = "DEFAULT";
      scroll-to-focused-application = true;
      show-apps-always-in-the-edge = true;
      show-apps-at-top = false;
      show-mounts = false;
      show-running = false;
      show-show-apps-button = false;
      show-trash = false;
      show-windows-preview = true;
      transparency-mode = "FIXED";
      workspace-agnostic-urgent-windows = false;
    };

    "org/gnome/shell/extensions/gsconnect" = {
      devices = [ "d3f8e1ea_67d0_44ff_91aa_7f6ec202db67" ];
      enabled = true;
      keep-alive-when-locked = true;
      missing-openssl = false;
      name = "DESKTOP-E323AF";
      show-indicators = false;
    };

    "org/gnome/shell/extensions/gsconnect/device/d3f8e1ea_67d0_44ff_91aa_7f6ec202db67" = {
      certificate-pem = "-----BEGIN CERTIFICATE-----\nMIIBkjCCATmgAwIBAgIBATAKBggqhkjOPQQDBDBTMS0wKwYDVQQDDCRkM2Y4ZTFl\nYV82N2QwXzQ0ZmZfOTFhYV83ZjZlYzIwMmRiNjcxFDASBgNVBAsMC0tERSBDb25u\nZWN0MQwwCgYDVQQKDANLREUwHhcNMjMwNTIzMjIwMDAwWhcNMzMwNTIzMjIwMDAw\nWjBTMS0wKwYDVQQDDCRkM2Y4ZTFlYV82N2QwXzQ0ZmZfOTFhYV83ZjZlYzIwMmRi\nNjcxFDASBgNVBAsMC0tERSBDb25uZWN0MQwwCgYDVQQKDANLREUwWTATBgcqhkjO\nPQIBBggqhkjOPQMBBwNCAAS2CDUaXsNAjSaTHqQoCp6jHFWzBgaKDE1MTW50ee6b\nCv5A/Y5W60NFojhxWZk/frnLpDiPGMqtb2Hvwrs6sOC8MAoGCCqGSM49BAMEA0cA\nMEQCIAFe10MZbSBYm92y9LEf8At4vMx5BZRXJxB2qRdcpUKJAiAVjtt2cYlMRVA/\n0xIQivJ6n8T/b5CZd4+fk9HJdDB5YQ==\n-----END CERTIFICATE-----\n";
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request_mute" ];
      last-connection = "lan://192.168.18.219:1716";
      name = "Redmi Note 13 Pro+ 5G";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      paired = true;
      supported-plugins = [ "battery" "clipboard" "connectivity_report" "contacts" "findmyphone" "mousepad" "mpris" "notification" "ping" "presenter" "runcommand" "sftp" "share" "sms" "systemvolume" "telephony" ];
      type = "phone";
    };

    "org/gnome/shell/extensions/gsconnect/device/d3f8e1ea_67d0_44ff_91aa_7f6ec202db67/plugin/battery" = {
      custom-battery-notification-value = mkUint32 80;
    };

    "org/gnome/shell/extensions/gsconnect/device/d3f8e1ea_67d0_44ff_91aa_7f6ec202db67/plugin/clipboard" = {
      receive-content = true;
      send-content = true;
    };

    "org/gnome/shell/extensions/gsconnect/device/d3f8e1ea_67d0_44ff_91aa_7f6ec202db67/plugin/notification" = {
      applications = ''
        {"Bottles":{"iconName":"com.usebottles.bottles","enabled":true},"Printers":{"iconName":"org.gnome.Settings-printers-symbolic","enabled":true},"Events and Tasks Reminders":{"iconName":"org.gnome.Evolution-alarm-notify","enabled":true},"Disks":{"iconName":"org.gnome.DiskUtility","enabled":true},"Software":{"iconName":"org.gnome.Software","enabled":true},"Date & Time":{"iconName":"org.gnome.Settings-time-symbolic","enabled":true},"Lutris":{"iconName":"net.lutris.Lutris","enabled":true},"Disk Usage Analyzer":{"iconName":"org.gnome.baobab","enabled":true},"Geary":{"iconName":"org.gnome.Geary","enabled":true},"Power":{"iconName":"org.gnome.Settings-power-symbolic","enabled":true},"Console":{"iconName":"org.gnome.Console","enabled":true},"Color Management":{"iconName":"org.gnome.Settings-color-symbolic","enabled":true},"Files":{"iconName":"org.gnome.Nautilus","enabled":true},"Clocks":{"iconName":"org.gnome.clocks","enabled":true},"discord":{"iconName":"","enabled":true},"Brave":{"iconName":"file:///tmp/.org.chromium.Chromium.scoped_dir.9GsVkk/logo.png","enabled":true},"Disk Space":{"iconName":"","enabled":true},"gnome-settings-daemon":{"iconName":"","enabled":true},"Mullvad VPN":{"iconName":"","enabled":true},"qBittorrent":{"iconName":"qbittorrent","enabled":true},"tidal-hifi":{"iconName":"","enabled":true}}
      '';
      send-active = false;
      send-notifications = false;
    };

    "org/gnome/shell/extensions/gsconnect/device/d3f8e1ea_67d0_44ff_91aa_7f6ec202db67/plugin/share" = {
      receive-directory = "/home/lpbigfish/Downloads";
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 784 550 ];
    };

    "org/gnome/shell/extensions/gtile" = {
      follow-cursor = false;
      show-icon = false;
    };

    "org/gnome/shell/extensions/lockscreen-extension" = {
      background-size-1 = "center";
      blur-brightness-1 = mkDouble "0.534782";
      blur-radius-1 = 22;
      gradient-direction-1 = "none";
      hide-lockscreen-extension-button = true;
      primary-color-1 = "#c9c9c9ff";
      secondary-color-1 = "#0f0f0fff";
      user-background-1 = true;
    };

    "org/gnome/shell/extensions/status-area-horizontal-spacing" = {
      hpadding = 5;
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      focus-hint-color = "rgb(53,132,228)";
      last-version-installed = 53;
      overridden-settings = [
        (mkDictionaryEntry ["org.gnome.mutter.edge-tiling" (mkVariant (mkNothing "b"))])
        (mkDictionaryEntry ["org.gnome.desktop.wm.keybindings.maximize" (mkVariant (mkNothing "b"))])
        (mkDictionaryEntry ["org.gnome.desktop.wm.keybindings.unmaximize" (mkVariant (mkNothing "b"))])
        (mkDictionaryEntry ["org.gnome.mutter.keybindings.toggle-tiled-left" (mkVariant (mkNothing "b"))])
        (mkDictionaryEntry ["org.gnome.mutter.keybindings.toggle-tiled-right" (mkVariant (mkNothing "b"))])
      ];
    };

    "org/gnome/shell/extensions/tilingshell" = {
      last-version-name-installed = "17.1";
      layouts-json = "[{\"id\":\"Layout 1\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.22,\"height\":0.5,\"groups\":[1,2]},{\"x\":0,\"y\":0.5,\"width\":0.22,\"height\":0.5,\"groups\":[1,2]},{\"x\":0.22,\"y\":0,\"width\":0.56,\"height\":1,\"groups\":[2,3]},{\"x\":0.78,\"y\":0,\"width\":0.22,\"height\":0.5,\"groups\":[3,4]},{\"x\":0.78,\"y\":0.5,\"width\":0.22,\"height\":0.5,\"groups\":[3,4]}]},{\"id\":\"Layout 2\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.22,\"height\":1,\"groups\":[1]},{\"x\":0.22,\"y\":0,\"width\":0.56,\"height\":1,\"groups\":[1,2]},{\"x\":0.78,\"y\":0,\"width\":0.22,\"height\":1,\"groups\":[2]}]},{\"id\":\"Layout 3\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.33,\"height\":1,\"groups\":[1]},{\"x\":0.33,\"y\":0,\"width\":0.67,\"height\":1,\"groups\":[1]}]},{\"id\":\"Layout 4\",\"tiles\":[{\"x\":0,\"y\":0,\"width\":0.67,\"height\":1,\"groups\":[1]},{\"x\":0.67,\"y\":0,\"width\":0.33,\"height\":1,\"groups\":[1]}]}]";
      overridden-settings = ''
        {}
      '';
      selected-layouts = [ [ "Layout 1" "Layout 1" ] [ "Layout 1" "Layout 1" ] ];
      window-use-custom-border-color = false;
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
    };

    "org/gnome/shell/world-clocks" = {
      locations = mkArray "v" [];
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1770579305;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1770579245;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ (mkDouble "0.8313725590705872") (mkDouble "0.929411768913269") (mkDouble "0.5411764979362488") (mkDouble "1.0") ]) (mkTuple [ (mkDouble "0.9490196108818054") (mkDouble "0.3607843220233917") (mkDouble "0.3294117748737335") (mkDouble "1.0") ]) (mkTuple [ (mkDouble "0.6274510025978088") (mkDouble "0.9019607901573181") (mkDouble "0.6392157077789307") (mkDouble "1.0") ]) (mkTuple [ (mkDouble "1.0") (mkDouble "0.95686274766922") (mkDouble "0.6941176652908325") (mkDouble "1.0") ]) ];
      selected-color = mkTuple [ true (mkDouble "1.0") (mkDouble "1.0") (mkDouble "1.0") (mkDouble "1.0") ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 167;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 56 50 ];
      window-size = mkTuple [ 1203 902 ];
    };

  };
}
