{ pkgs, lib, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/refs/heads/main/pack.toml";
    packHash = "sha256-dZc/qo5uV15LZZNPhMUa3avPEetjq8igdxqb+aLTZLM=";
  };
in {
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.fabric = {
      enable = true;

      package = pkgs.fabricServers.fabric-1_21_10.override {
        loaderVersion = "0.18.0";
      };

      symlinks = {
        mods = "${modpack}/mods";
      };

      serverProperties = {
        difficulty = 3;
        max-players = 10;
      };

      jvmOpts = "-Xmx4096M";
    };
  };

  services.tailscale.enable = true;
}