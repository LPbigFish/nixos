{ pkgs, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/fb3f949404ace81b1eb4bea0c437649ce3970058/pack.toml";
    packHash = "sha256-34b145ffcd9a279c774ec54feef92a3f097ab61f47b9f681b6a6c0a6b04a35b2";
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
        difficulty = 2;
        max-players = 12;
        spawn-protection = 0;
        level-seed = "-7266280065385116388";
      };

      jvmOpts = "-Xmx4096M";
    };
  };

  services.tailscale.enable = true;
}