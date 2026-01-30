{ config, pkgs, ... }:

let
  peer-port = 51412;
  web-port = 8112;
in {
  
  services.rtorrent = {
    enable = true;
    port = peer-port;
    package = pkgs.rtorrent;
    openFirewall = false;
  };
  systemd.services.rtorrent.serviceConfig.LimitNOFILE = 16384;

  services.flood = {
    enable = true;
    port = web-port;
    openFirewall = false;
    extraArgs = ["--rtsocket=${config.services.rtorrent.rpcSocket}"];
  };
  systemd.services.flood.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
}