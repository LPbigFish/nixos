{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.terraria;
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
      type = lib.types.enum [
        "small"
        "medium"
        "large"
      ];
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
      tmuxCmd = "${lib.getExe pkgs.tmux} -S ${lib.escapeShellArg tmuxSock}";
      session = "terraria";

      # flagsList built exactly like before (no quotes inside values)
      worldSizeMap = {
        small = 1;
        medium = 2;
        large = 3;
      };
      flagsList = [
        "-port"
        (toString cfg.port)
        "-maxPlayers"
        (toString cfg.maxPlayers)
      ]
      ++ lib.optionals (cfg.password != null) [
        "-password"
        cfg.password
      ]
      ++ lib.optionals (cfg.messageOfTheDay != null) [
        "-motd"
        cfg.messageOfTheDay
      ]
      ++ lib.optionals (cfg.worldPath != null) [
        "-world"
        cfg.worldPath
        "-autocreate"
        (toString (builtins.getAttr cfg.autoCreatedWorldSize worldSizeMap))
      ]
      ++ lib.optionals (cfg.banListPath != null) [
        "-banlist"
        cfg.banListPath
      ]
      ++ lib.optionals cfg.secure [ "-secure" ]
      ++ lib.optionals cfg.noUPnP [ "-noupnp" ];

      launcher = pkgs.writeShellScript "terraria-launch" ''
        set -euo pipefail
        export HOME=${lib.escapeShellArg cfg.dataDir}
        cd ${lib.escapeShellArg cfg.dataDir}

        echo "Launching: ${cfg.package}/bin/TerrariaServer ${
          lib.concatMapStringsSep " " lib.escapeShellArg flagsList
        }"

        exec ${cfg.package}/bin/TerrariaServer ${lib.concatMapStringsSep " " lib.escapeShellArg flagsList}
      '';

      startScript = pkgs.writeShellScript "terraria-start" ''
        set -euo pipefail
        # kill any stale session with the same name (ignore errors)
        ${tmuxCmd} has-session -t ${session} 2>/dev/null && ${tmuxCmd} kill-session -t ${session} || true
        # create a fresh detached session running our launcher
        exec ${tmuxCmd} new-session -d -s ${session} ${lib.escapeShellArg launcher}
      '';

      stopScript = pkgs.writeShellScript "terraria-stop" ''
        set -euo pipefail
        # If no tmux server/session, nothing to do.
        if ! ${tmuxCmd} has-session -t ${session} 2>/dev/null; then
          exit 0
        fi
        # Look at last line to decide whether a world is loaded
        lastline="$(${tmuxCmd} capture-pane -pt ${session}:0 -J -p | grep . | tail -n1 || true)"
        if [[ "$lastline" =~ ^'Choose World' ]]; then
          ${tmuxCmd} kill-session -t ${session} || true
        else
          ${tmuxCmd} send-keys -t ${session}:0 Enter exit Enter
        fi
        # Wait until the session disappears
        for i in $(seq 1 100); do
          if ! ${tmuxCmd} has-session -t ${session} 2>/dev/null; then
            exit 0
          fi
          sleep 0.1
        done
        # Force kill if needed
        ${tmuxCmd} kill-session -t ${session} || true
      '';
    in
    {
      users.users.terraria = {
        description = "Terraria server user";
        group = "terraria";
        home = cfg.dataDir;
        createHome = lib.mkDefault true;
        isSystemUser = true;
        shell = pkgs.bashInteractive;
      };
      users.groups.terraria = { };

      systemd.services.terraria = {
        description = "Terraria Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          User = "terraria";
          Group = "terraria";

          # tmux backgrounds; we don't track a PID
          Type = "oneshot";
          RemainAfterExit = true;

          UMask = 007;
          WorkingDirectory = cfg.dataDir;
          Environment = [ "HOME=${cfg.dataDir}" ];
          RequiresMountsFor = [ cfg.dataDir ];

          ExecStart = startScript;
          ExecStop = stopScript;
        };
      };

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.port ];
        allowedUDPPorts = [ cfg.port ];
      };
    }
  );
}
