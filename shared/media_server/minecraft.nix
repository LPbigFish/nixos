{ pkgs, lib, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/f62012acee4010b526b3a946cca30ec1001742a7/pack.toml";
    packHash = "sha256-1r5m6l3rhnpjvfmw6sf5qngby50cwl3np31j0asd9mr4n6yhbx45";
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