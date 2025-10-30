{ config, lib, pkgs, ... }:

let
  cfg = config.services.terraria;

  worldSizeMap = {
    small  = 1;
    medium = 2;
    large  = 3;
  };

in
{
  ###### Options ######
  options.services.terraria = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        If enabled, starts a Terraria server. Attach with:
        tmux -S ${config.services.terraria.dataDir}/terraria.sock attach
        (use C-b d to detach).
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.terraria-server;
      defaultText = lib.literalExpression "pkgs.terraria-server";
      description = "The Terraria server package to run (override for aarch64/Mono build).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = "TCP/UDP port to listen on.";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.ints.u8;
      default = 255;
      description = "Maximum number of players (1–255).";
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Server password, or null for no password.";
    };

    messageOfTheDay = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Message of the day text.";
    };

    # IMPORTANT: runtime path, not lib.types.path
    worldPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/srv/terraria/MyWorld.wld";
      description = ''
        Absolute path to the world file (.wld) to load/create. This must be a
        runtime path (e.g., /srv/terraria/World.wld), not a Nix store path.
        If set and the file does not exist, a new world will be created using
        autoCreatedWorldSize.
      '';
    };

    autoCreatedWorldSize = lib.mkOption {
      type = lib.types.enum [ "small" "medium" "large" ];
      default = "medium";
      description = "Size of an auto-created world (used only when worldPath is set and missing).";
    };

    # IMPORTANT: runtime path, not lib.types.path
    banListPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/srv/terraria/banlist.txt";
      description = "Absolute path to the ban list file.";
    };

    secure = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Adds additional cheat protection to the server (-secure).";
    };

    noUPnP = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable automatic UPnP (-noupnp).";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the port in the firewall.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/terraria";
      example = "/srv/terraria";
      description = "Directory for worlds, configs and tmux socket.";
    };
  };

  ###### Implementation ######
  config = lib.mkIf cfg.enable (
    let
      tmuxSock = "${cfg.dataDir}/terraria.sock";
      tmuxExec = "${lib.getExe pkgs.tmux} -S ${lib.escapeShellArg tmuxSock}";

      # Build a clean argv list; no embedded quotes.
      flagsList =
        [
          "-port"       (toString cfg.port)
          "-maxPlayers" (toString cfg.maxPlayers)
        ]
        ++ lib.optionals (cfg.password != null)          [ "-password" cfg.password ]
        ++ lib.optionals (cfg.messageOfTheDay != null)   [ "-motd"     cfg.messageOfTheDay ]
        ++ lib.optionals (cfg.worldPath != null)         [ "-world"    cfg.worldPath
                                                           "-autocreate" (toString (builtins.getAttr cfg.autoCreatedWorldSize worldSizeMap)) ]
        ++ lib.optionals (cfg.banListPath != null)       [ "-banlist"  cfg.banListPath ]
        ++ lib.optionals cfg.secure                       [ "-secure" ]
        ++ lib.optionals cfg.noUPnP                       [ "-noupnp" ];

      # Tiny launcher so systemd/tmux don't mangle args. We expand the flags
      # with proper shell-escaping here.
      launcher = pkgs.writeShellScript "terraria-launch" ''
        set -euo pipefail
        export HOME=${lib.escapeShellArg cfg.dataDir}
        cd ${lib.escapeShellArg cfg.dataDir}

        # Print args for debugging once
        echo "Starting Terraria: ${lib.escapeShellArg (cfg.package.outPath)}/bin/TerrariaServer ${lib.concatMapStringsSep " " lib.escapeShellArg flagsList}"

        exec ${cfg.package}/bin/TerrariaServer ${lib.concatMapStringsSep " " lib.escapeShellArg flagsList}
      '';

      # Graceful stop helper: either exit at prompt or send "exit"
      stopScript = pkgs.writeShellScript "terraria-stop" ''
        if ! [ -d "/proc/$1" ]; then
          exit 0
        fi

        lastline=$(${tmuxExec} capture-pane -p | grep . | tail -n1 || true)

        if [[ "$lastline" =~ ^'Choose World' ]]; then
          ${tmuxExec} kill-session || true
        else
          ${tmuxExec} send-keys Enter exit Enter
        fi

        # Wait for process
        tail --pid="$1" -f /dev/null
      '';
    in
    {
      users.users.terraria = {
        description = "Terraria server user";
        group = "terraria";
        home = cfg.dataDir;
        isSystemUser = true;
        # Let tmpfiles (or existing dir) control mode/creation if desired.
        createHome = lib.mkDefault true;
      };

      users.groups.terraria = { };

      systemd.services.terraria = {
        description = "Terraria Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          User = "terraria";
          Group = "terraria";

          # We run Terraria inside a tmux session so you can attach.
          Type = "forking";
          GuessMainPID = true;

          # Terraria writes config/logs/world; 007 to keep group readable if needed.
          UMask = 007;

          # Make HOME/CWD explicit so default world discovery works:
          WorkingDirectory = cfg.dataDir;
          Environment = [ "HOME=${cfg.dataDir}" ];

          # Ensure the data dir mount exists before starting
          RequiresMountsFor = [ cfg.dataDir ];

          # Use a launcher to avoid quoting issues
          ExecStart = "${tmuxExec} new -d ${launcher}";
          ExecStop  = "${stopScript} $MAINPID";
        };
      };

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.port ];
        allowedUDPPorts = [ cfg.port ];
      };
    }
  );
}
