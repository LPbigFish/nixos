{ pkgs, lib, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/fb3f949404ace81b1eb4bea0c437649ce3970058/pack.toml";
    packHash = "sha256-MtfBhCAZwNH+9Cs8d/6LmKIQg/nbzj3ht9el2NzfdFw=";
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