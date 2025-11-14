{ pkgs, ... }:
let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/refs/heads/main/pack.toml";
    packHash = "sha256-1im8bk0c5rcnphl1hibkypy678bjx60a65kbf92mrs6s2xmky8wd";
  };
in {
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.fabric = {
      enable = true;

      package = pkgs.fabricServers.fabric-1_21_10.override {
        loaderVersion = "0.17.3";
      };

      symlinks = {
        mods = "${modpack}/mods";
      };
    };
  };

  services.tailscale.enable = true;
}