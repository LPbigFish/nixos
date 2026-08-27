# Shared infrastructure registry (plain data + validation).
# Consumed by every host evaluation via specialArgs and by deploy-rs.
{ lib }:

let
  hosts = import ./hosts.nix;
  services = import ./services.nix;

  fail = cond: msg: if cond then null else throw msg;

  portOk = p: lib.isInt p && p >= 1 && p <= 65535;

  unknown = allowed: attrs: lib.subtractLists allowed (lib.attrNames attrs);

  serviceKeys = [
    "host"
    "web"
    "tcp"
    "udp"
  ];
  webKeys = [
    "port"
    "domain"
    "proxyExtraConfig"
  ];
  tcpKeys = [
    "port"
    "publicPort"
  ];
  udpKeys = [
    "port"
    "publicPort"
    "proxy"
  ];

  checkService =
    name: svc:
    let
      checks = [
        (fail (unknown serviceKeys svc == [ ])
          "infra: service '${name}': unsupported keys ${toString (unknown serviceKeys svc)} (supported: ${toString serviceKeys})"
        )
        (fail (svc ? host) "infra: service '${name}': missing 'host'")
        (fail (builtins.hasAttr svc.host hosts) "infra: service '${name}': unknown host '${toString svc.host}'")
        (fail (
          svc ? web || svc ? tcp || svc ? udp
        ) "infra: service '${name}': needs at least one of web/tcp/udp")
        (fail (!(svc ? web) || unknown webKeys svc.web == [ ])
          "infra: service '${name}'.web: unsupported keys ${
            toString (if svc ? web then unknown webKeys svc.web else [ ])
          }"
        )
        (fail (!(svc ? tcp) || unknown tcpKeys svc.tcp == [ ])
          "infra: service '${name}'.tcp: unsupported keys ${
            toString (if svc ? tcp then unknown tcpKeys svc.tcp else [ ])
          }"
        )
        (fail (!(svc ? udp) || unknown udpKeys svc.udp == [ ])
          "infra: service '${name}'.udp: unsupported keys ${
            toString (if svc ? udp then unknown udpKeys svc.udp else [ ])
          }"
        )
        (fail (!(svc ? web) || portOk svc.web.port)
          "infra: service '${name}'.web.port: invalid port ${toString (svc.web.port or null)}"
        )
        (fail (
          !(svc ? web) || lib.isString svc.web.domain && svc.web.domain != ""
        ) "infra: service '${name}'.web.domain: invalid")
        (fail (
          !(svc ? tcp) || portOk svc.tcp.port && portOk svc.tcp.publicPort
        ) "infra: service '${name}'.tcp: invalid port")
        (fail (
          !(svc ? udp) || portOk svc.udp.port && portOk svc.udp.publicPort
        ) "infra: service '${name}'.udp: invalid port")
      ];
    in
    builtins.deepSeq checks null;

  hostChecks = lib.mapAttrsToList (
    name: h:
    if h.deploy or false then
      fail (
        (lib.isString (h.sshHostname or null) && h.sshHostname != "")
        && (lib.isString (h.sshUser or null) && h.sshUser != "")
      ) "infra: host '${name}': deploy = true requires sshHostname and sshUser"
    else
      null
  ) hosts;

  webDomains = lib.concatLists (
    lib.mapAttrsToList (_: s: lib.optional (s ? web) s.web.domain) services
  );
  tcpPublic = lib.concatLists (
    lib.mapAttrsToList (_: s: lib.optional (s ? tcp) s.tcp.publicPort) services
  );
  udpPublic = lib.concatLists (
    lib.mapAttrsToList (_: s: lib.optional (s ? udp) s.udp.publicPort) services
  );

  dupCheck =
    what: values:
    let
      dups = lib.filter (v: lib.count (x: x == v) values > 1) (lib.unique values);
    in
    fail (dups == [ ]) "infra: duplicate ${what}: ${toString dups}";

  # Ports the gateway itself needs (ssh / nginx / wireguard)
  reserved = [
    22
    80
    443
    51820
  ];
  reservedClash = lib.filter (p: lib.elem p reserved) (tcpPublic ++ udpPublic);
in
builtins.deepSeq (
  lib.mapAttrsToList checkService services
  ++ hostChecks
  ++ [
    (dupCheck "web domains" webDomains)
    (dupCheck "public TCP ports" tcpPublic)
    (dupCheck "public UDP ports" udpPublic)
    (fail (
      reservedClash == [ ]
    ) "infra: public ports clash with gateway ssh/http/https/wireguard: ${toString reservedClash}")
  ]
) { inherit hosts services; }
