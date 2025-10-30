{ config, lib, options, pkgs, ... }:

let
  # Get config and options for *our* module
  cfg = config.services.tshock;
  opt = options.services.tshock; # Used for linking in descriptions

  # Helper function to create flags like: -name value
  # TShock flags (e.g., -port 7777) are simpler than vanilla's (-port "7777")
  valFlag = name: val:
    lib.optionalString (val != null) "-${name} ${lib.escapeShellArg (toString val)}";

  # Build the list of TShock-specific command-line flags
  flags = [
    (valFlag "port" cfg.port)
    (valFlag "maxplayers" cfg.maxPlayers) # Note: TShock uses 'maxplayers'
    (valFlag "password" cfg.password)
    (valFlag "motd" cfg.messageOfTheDay)
    (valFlag "world" cfg.worldPath)
    (valFlag "banlist" cfg.banListPath)
  ];

  # Command to run tmux with a TShock-specific socket
  tmuxCmd = "${lib.getExe pkgs.tmux} -S ${lib.escapeShellArg cfg.dataDir}/tshock.sock";

  # Simplified stop script for TShock
  # TShock doesn't have the "Choose World" prompt if -world is specified.
  # It just needs the 'exit' command to save and quit.
  stopScript = pkgs.writeShellScript "tshock-stop" ''
    #!${pkgs.runtimeShell}
    # Check if the process (PID $1) exists
    if ! [ -d "/proc/$1" ]; then
      exit 0
    fi

    # TShock gracefully exits with the "exit" command
    ${tmuxCmd} send-keys exit Enter

    # Wait for the process to stop
    tail --pid="$1" -f /dev/null
  '';

in
{
  #
  # === OPTIONS DEFINITION ===
  #
  options = {
    services.tshock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If enabled, starts a TShock Terraria server. The server can be connected
          to via `tmux -S ''${config.${opt.dataDir}}/tshock.sock attach`
          for administration by users who are a part of the `tshock` group
          (use `C-b d` shortcut to detach again).
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 7777;
        description = "Specifies the port to listen on.";
      };

      maxPlayers = lib.mkOption {
        type = lib.types.ints.u8;
        default = 16;
        description = "Sets the max number of players.";
      };

      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Sets the server password. Leave `null` for no password.";
      };

      messageOfTheDay = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Set the server message of the day text.";
      };

      worldPath = lib.mkOption {
        type = lib.types.path; # TShock requires a world path
        default = "${cfg.dataDir}/Worlds/world.wld";
        description = ''
          The path to the world file (`.wld`) which should be loaded.
          TShock will create this world on first start if it doesn't exist.
        '';
      };

      banListPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = "${cfg.dataDir}/tshock/bans.txt";
        description = "The path to the ban list.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the server port in the firewall.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/tshock";
        example = "/srv/tshock";
        description = "Path to variable state data directory for TShock.";
      };
    };
  };

  #
  # === CONFIGURATION ===
  #
  config = lib.mkIf cfg.enable {
    # Create the user and group
    users.users.tshock = {
      description = "TShock server service user";
      group = "tshock";
      home = cfg.dataDir;
      createHome = true;
      # Use dynamic IDs, or set static ones if you prefer
      isSystemUser = true;
    };

    users.groups.tshock = {
      # Use dynamic ID
    };

    # The systemd service
    systemd.services.tshock = {
      description = "TShock Terraria Server Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = "tshock";
        Group = "tshock";
        Type = "forking";
        GuessMainPID = true;

        # TShock *must* run in its data directory to find its config
        # file (`config.json`), Worlds, and plugin folders.
        WorkingDirectory = cfg.dataDir;

        # Run the TShock executable from the nix store
        ExecStart =
          "${tmuxCmd} new -d ${pkgs.tshock}/bin/TShock ${lib.concatStringsSep " " flags}";

        ExecStop = "${stopScript} $MAINPID";

        # Optional: Auto-restart on crash
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    # Open the firewall
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}