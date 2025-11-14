{ pkgs, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/LPbigFish/FabricMods/blob/main/pack.toml";
    packHash = "sha256-0qq0v021ziq3jb6yf24p06ynxhzib5x3szf1vbsjxhn5365k6lz1";
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
    };
  };

  services.tailscale.enable = true;
}