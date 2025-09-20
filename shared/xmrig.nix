{
  description = "XMRig (RandomX) over Tor to LAN/hidden-service daemon";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
  let
    forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed
      (system: f (import nixpkgs { inherit system; }));
  in {
    nixosModules.xmrig-tor-solo = { config, lib, pkgs, ... }:
    let
      cfg = config.services.xmrigSolo;
      inherit (lib) mkEnableOption mkOption types mkIf optionalString;
      json = pkgs.formats.json {};
      xmrigConfig = json.generate "xmrig-config.json" {
        autosave = true;
        cpu = {
          enabled = true;
          huge-pages = true;
          # Hint threads (%) — good starting point for 12600KF is 75–100
          max-threads-hint = cfg.maxThreadsHint;
          asm = true;
        };
        randomx = {
          "1gb-pages" = cfg.oneGiBHugePages;
          numa = false;
        };
        pools = [
          {
            # Put creds in URL so XMRig does HTTP Basic auth to monerod RPC.
            # We force http scheme so xmrig doesn't try TLS; traffic is inside Tor.
            url = "http://${cfg.rpcUser}:${cfg.rpcPass}@${cfg.onion}:18089";
            daemon = true;
            user = cfg.wallet;    # where block rewards go
            pass = "x";
            tls = false;
            # route via local Tor SOCKS
            socks5 = "${cfg.torSocksHost}:${toString cfg.torSocksPort}";
            keepalive = true;
            rig-id = cfg.rigId;
            nicehash = false;
          }
        ];
      };
    in {
      options.services.xmrigSolo = {
        enable = mkEnableOption "XMRig solo mining over Tor to a daemon";
        onion = mkOption {
          type = types.str;
          example = "yourhiddenserviceaddress.onion";
          description = "Tor .onion host of your monerod RPC (HiddenServicePort 18089).";
        };
        wallet = mkOption {
          type = types.str;
          example = "44Affq5kSiGBoZ..."; # Monero address
          description = "Destination wallet address for block rewards.";
        };
        rpcUser = mkOption {
          type = types.str;
          default = "miner";
          description = "monerod --rpc-login username.";
        };
        rpcPass = mkOption {
          type = types.str;
          default = "change-me";
          description = "monerod --rpc-login password.";
        };
        rigId = mkOption {
          type = types.str;
          default = "nixos-laptop";
          description = "Identifier shown in logs.";
        };
        maxThreadsHint = mkOption {
          type = types.int;
          default = 90; # % of logical threads; tune per machine
          description = "XMRig max-threads-hint (percentage).";
        };
        oneGiBHugePages = mkOption {
          type = types.bool;
          default = false;
          description = "Try 1GiB huge pages (Linux support varies; 2MiB pages still used).";
        };
        nrHugepages = mkOption {
          type = types.int;
          default = 4096;
          description = "vm.nr_hugepages (2MiB pages). Bump if running many threads.";
        };
        acOnly = mkOption {
          type = types.bool;
          default = true;
          description = "Start miner only when on AC power.";
        };
        idleTimer.enable = mkOption {
          type = types.bool;
          default = false;
          description = "Start miner when system is idle (systemd timer OnIdleSec).";
        };
        idleTimer.onIdleSec = mkOption {
          type = types.str;
          default = "2min";
          description = "How long the system must be idle before starting miner.";
        };
        serviceExtraArgs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Extra CLI args for xmrig (e.g., \"--background\").";
        };
        user = mkOption {
          type = types.str;
          default = "xmrig";
          description = "System user to run the miner.";
        };
        group = mkOption {
          type = types.str;
          default = "xmrig";
          description = "System group to run the miner.";
        };
        torSocksHost = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Tor SOCKS host used by XMRig.";
        };
        torSocksPort = mkOption {
          type = types.port;
          default = 9050;
          description = "Tor SOCKS port used by XMRig.";
        };
      };

      config = mkIf cfg.enable {
        # Tor client with SOCKS5 for XMRig
        services.tor = {
          enable = true;
          client.enable = true;
          settings = {
            SocksPort = [ "${cfg.torSocksHost}:${toString cfg.torSocksPort}" ];
          };
        };

        # Huge pages for RandomX
        boot.kernel.sysctl = {
          "vm.nr_hugepages" = cfg.nrHugepages;
        };

        users.users.${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
        };
        users.groups.${cfg.group} = {};

        environment.systemPackages = [ pkgs.xmrig ];

        # Drop the config to /etc/xmrig/config.json
        environment.etc."xmrig/config.json".source = xmrigConfig;

        systemd.services.xmrig = {
          description = "XMRig RandomX miner (Tor → monerod)";
          after = [ "network-online.target" "tor.service" ];
          wants = [ "network-online.target" "tor.service" ];
          wantedBy = [ "multi-user.target" ];
          environment = {
            # ensure predictable huge page behavior
            XMRIG_NO_AVX2 = "0";
          };
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            ExecStart = ''
              ${pkgs.xmrig}/bin/xmrig \
                -c /etc/xmrig/config.json ${lib.concatStringsSep " " cfg.serviceExtraArgs}
            '';
            # Huge pages + mlock
            LimitMEMLOCK = "infinity";
            AmbientCapabilities = [ "CAP_IPC_LOCK" ];
            CapabilityBoundingSet = [ "CAP_IPC_LOCK" ];
            # Keep the laptop responsive
            Nice = 10;
            IOSchedulingClass = "best-effort";
            IOSchedulingPriority = 7;
            # Bind fewer CPUs if you want (example commented)
            # CPUAffinity = 0 2 4 6 8 10
            Restart = "always";
            RestartSec = "10s";
            # Only run on AC if desired
            ${optionalString cfg.acOnly "ConditionACPower=true;"}
          };
        };

        # Optional: start when system is idle
        systemd.timers."xmrig-idle" = mkIf cfg.idleTimer.enable {
          description = "Start XMRig when system is idle";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitInactiveSec = "5min";
            OnIdleSec = cfg.idleTimer.onIdleSec;
            Unit = "xmrig.service";
          };
        };
      };
    };

    # Example host configuration you can use as a template:
    nixosConfigurations.example = forAllSystems (pkgs: pkgs.lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        ({ ... }: {
          imports = [ self.nixosModules.xmrig-tor-solo ];
          services.xmrigSolo = {
            enable = true;
            onion = "yourhiddenserviceaddress.onion";
            wallet = "48XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
            rpcUser = "miner";
            rpcPass = "super-strong-password";
            rigId = "nixos-laptop";
            maxThreadsHint = 90;
            oneGiBHugePages = false;
            nrHugepages = 4096;
            acOnly = true;
            idleTimer.enable = false; # set true if you want idle-triggered start
            serviceExtraArgs = [ "--print-time=30" ];
          };
        })
      ];
    });
  };
}