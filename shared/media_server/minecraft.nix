{ pkgs, lib, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/7541fa2664a1737b8253aa92763174c25f7ee8c3/pack.toml";
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
        level-seed = "-7266280065385116388";
        online-mode = false;
      };

      jvmOpts = "-Xmx4096M";
    };
  };

  services.tailscale.enable = true;
}