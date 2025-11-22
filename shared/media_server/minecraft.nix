{ pkgs, lib, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/611d51c64d25ec16703308590a3d8369ddc7507e/pack.toml";
    packHash = lib.fakeSha256;
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
        max-players = 12;
        spawn-protection = 0;
        level-seed = "-7266280065385116388";
      };

      jvmOpts = "-Xmx4096M";
    };
  };

  services.tailscale.enable = true;
}