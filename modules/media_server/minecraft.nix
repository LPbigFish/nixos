{ pkgs, lib, ... }:
let
  modpack_normal = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/FabricMods/2252cca5909f84757501388c862809f194b4e8b5/pack.toml";
    packHash = "sha256-7a5cTHxAK1xg5kHnWrppvA54+pcFjo/gscqDiiH8bVA=";
  };

  modpack_spookers = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/LPbigFish/HorrorMods/1e997dbbae2b361236c56190febf02112e9c1720/pack.toml";
    packHash = lib.fakeHash;
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers = {
      fabric = {
        enable = false;

        package = pkgs.fabricServers.fabric-1_21_10.override {
          loaderVersion = "0.18.0";
        };

        symlinks = {
          mods = "${modpack_normal}/mods";
        };

        serverProperties = {
          difficulty = 3;
          max-players = 12;
          spawn-protection = 0;
          level-seed = "-7266280065385116388";
        };

        jvmOpts = "-Xmx4096M";
      };
      spookers = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_20_1.override {
          loaderVersion = "0.18.4";

          serverProperties = {
            difficulty = 3;
            max-players = 12;
            spawn-protection = 0;
            level-seed = "-7266280065385116388";
            white-list = true;
          };

          jvmOpts = "-Xmx4096M";
        };
      };
    };
  };

  services.tailscale.enable = true;
}
