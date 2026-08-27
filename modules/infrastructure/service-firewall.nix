# Application hosts: open service ports on the WireGuard interface only,
# derived from the services assigned to this host in infra.services.
{
  lib,
  infra,
  hostName,
  ...
}:

let
  onVpn = ((infra.hosts.${hostName} or { }).vpnAddress or null) != null;

  mine = lib.attrValues (lib.filterAttrs (_: svc: svc.host == hostName) infra.services);
  webPorts = map (svc: svc.web.port) (lib.filter (svc: svc ? web) mine);
  tcpPorts = map (svc: svc.tcp.port) (lib.filter (svc: svc ? tcp) mine);
  udpPorts = map (svc: svc.udp.port) (lib.filter (svc: svc ? udp) mine);
in
{
  networking.firewall.interfaces.wg0 = lib.mkIf onVpn {
    # 22 kept for administration over the VPN, the rest are
    # gateway-reachable service ports.
    allowedTCPPorts = [ 22 ] ++ webPorts ++ tcpPorts;
    allowedUDPPorts = udpPorts;
  };
}
