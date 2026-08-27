# Gateway host (public VPS): derives nginx virtual hosts, raw TCP/UDP
# forwarding and firewall openings from infra.services.
{
  lib,
  infra,
  hostName,
  ...
}:

let
  isGateway = (infra.hosts.${hostName} or { }).gateway or false;

  addrOf = name: infra.hosts.${name}.vpnAddress;

  webServices = lib.filterAttrs (_: svc: svc ? web) infra.services;
  tcpServices = lib.filterAttrs (_: svc: svc ? tcp) infra.services;
  udpForwarded = lib.filterAttrs (_: svc: svc ? udp && (svc.udp.proxy or true)) infra.services;
  udpAll = lib.filterAttrs (_: svc: svc ? udp) infra.services;

  streamServer = proto: svc: ''
    server {
      listen ${toString svc.${proto}.publicPort}${lib.optionalString (proto == "udp") " udp"};
      proxy_pass ${addrOf svc.host}:${toString svc.${proto}.port};
      proxy_timeout 600s;
      proxy_connect_timeout 30s;
    }
  '';

  hasStream =
    (lib.length (lib.attrValues tcpServices) + lib.length (lib.attrValues udpForwarded)) > 0;
in
{
  config = lib.mkIf isGateway {
    security.acme = {
      acceptTerms = true;
      defaults.email = "lpbigfish@proton.me";
    };

    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      virtualHosts = builtins.listToAttrs (
        lib.map (
          svc:
          lib.nameValuePair svc.web.domain {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://${addrOf svc.host}:${toString svc.web.port}";
              extraConfig = svc.web.proxyExtraConfig or "";
            };
          }
        ) (lib.attrValues webServices)
      );
      streamConfig = lib.mkIf hasStream (
        lib.concatStrings (
          lib.mapAttrsToList (_: svc: streamServer "tcp" svc) tcpServices
          ++ lib.mapAttrsToList (_: svc: streamServer "udp" svc) udpForwarded
        )
      );
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ]
      ++ map (svc: svc.tcp.publicPort) (lib.attrValues tcpServices);
      allowedUDPPorts = map (svc: svc.udp.publicPort) (lib.attrValues udpAll);
    };
  };
}
