# Agent guide: LPbigFish NixOS infrastructure

This file applies to the whole repository. It is a NixOS flake for a small
fleet, not a conventional application repository. The root flake is the
source of truth for system configuration, deployment topology, packages, and
infrastructure wiring.

## Repository model

The evaluation path is:

1. `flake.nix` imports and validates `infra/`.
2. `modules/profiles.nix` assembles each named NixOS profile from shared and
   host-specific modules.
3. `flake.nix` turns those profiles into `nixosConfigurations` and, for hosts
   marked `deploy = true`, `deploy.nodes` entries for deploy-rs.
4. `modules/infrastructure/` consumes the validated registry and generates
   gateway proxying and backend firewall openings.

`mkHost` passes `inputs`, `infra`, and `hostName` to every host module. It also
adds weekly `system.autoUpgrade` to non-deployed hosts. Hosts managed by
deploy-rs deliberately do not auto-upgrade; deploy-rs owns their activation.

Important source-of-truth files:

- `flake.nix`: inputs, outputs, NixOS configurations, deploy-rs nodes, checks.
- `modules/profiles.nix`: exact module composition for every host profile.
- `infra/hosts.nix`: host metadata, architecture, VPN addresses, and deploy
  connection data.
- `infra/services.nix`: services that participate in gateway exposure and
  generated firewall rules.
- `infra/default.nix`: schema validation, duplicate checks, and reserved-port
  checks for the infrastructure registry.
- `modules/infrastructure/gateway.nix`: gateway nginx, ACME, TCP/UDP stream
  forwarding, and public firewall openings.
- `modules/infrastructure/service-firewall.nix`: backend service ports opened
  only on `wg0`.

## Hosts and topology

| Profile | Architecture | Role | Management |
| --- | --- | --- | --- |
| `main` | `x86_64-linux` | Main desktop, NVIDIA, GNOME, containers | Local rebuild / auto-upgrade |
| `laptop` | `x86_64-linux` | Intel laptop, GNOME, containers | Local rebuild / auto-upgrade |
| `wsl` | `x86_64-linux` | NixOS-WSL, Docker with NVIDIA runtime | Local rebuild / auto-upgrade |
| `minimal` | `x86_64-linux` | Minimal local install profile | Local rebuild / auto-upgrade |
| `netcup` | `x86_64-linux` | Public VPS gateway | deploy-rs |
| `orangepi5pro` | `aarch64-linux` | Orange Pi 5 Pro backend/media host | deploy-rs |

The server path is:

```text
Internet
  -> netcup public VPS (37.120.168.146, WireGuard 10.100.0.1)
  -> WireGuard wg0
  -> orangepi5pro (10.100.0.2, LAN 192.168.18.76)
```

`netcup` is the only host with `gateway = true`. It terminates public HTTPS
with nginx/ACME and forwards configured services over WireGuard. `orangepi5pro`
uses U-Boot/extlinux rather than GRUB or systemd-boot; its SD card carries
`/boot`. Its Wi-Fi access point is `OrangeBox` on `192.168.50.1/27`, with
dnsmasq DHCP and NAT through `enP4p65s0`.

The flake supports an optional `sshProxyJump` field for deploy-rs, but it is
not currently set in `infra/hosts.nix`; the current Orange Pi deploy hostname
is the LAN address `192.168.18.76`. Treat comments or older README text that
describe a proxy jump as stale unless the registry is changed too.

## Service exposure

Add a service to `infra/services.nix` only when it should participate in the
shared gateway/firewall model. Each service has one backend `host` and may
define:

- `web = { port; domain; proxyExtraConfig ? ...; }`: HTTPS reverse proxy on
  the gateway to the backend's WireGuard address.
- `tcp = { port; publicPort; }`: raw TCP stream forwarding on the gateway.
- `udp = { port; publicPort; proxy ? true; }`: UDP forwarding; `proxy = false`
  suppresses the gateway stream proxy but still records the public port.

The registry validates host names, keys, ports, duplicate domains/public
ports, and collisions with gateway ports `22`, `80`, `443`, and `51820`.

The current registry contains one public web service:

- `couchdb` on `orangepi5pro`, backend port `5984`, exposed as
  `https://couchdb.lpbigfish.xyz` through the `netcup` gateway.

For a web service, the gateway opens `80/443` and the backend opens the service
port on `wg0`. Do not manually duplicate these generated openings unless the
service is intentionally outside the registry model. Host-local services can
still have their own explicit firewall rules.

## Profile composition

Every profile includes the shared modules in `modules/profiles.nix`, notably:

- `modules/infrastructure` for generated network policy.
- `modules/default.nix` for common tools, Nix settings, `nh`, shell defaults,
  fonts, and graphics-driver selection.
- Disko and nix-minecraft inputs where configured.

Host-specific configuration lives under `hosts/<profile>/`. The server profile
`orangepi5pro` additionally imports the RK3588 board module, SOPS, Tor,
PostgreSQL, Minecraft, Nextcloud, Moodle, CouchDB, and the Polymarket Scanner
module. Importing a module does not mean its service is active: inspect the
service's own `enable` flag. For example, CouchDB is enabled, while the
Polymarket Scanner and Moodle are currently disabled; several other media
modules are commented out in `modules/profiles.nix`.

Use `system.stateVersion` values as historical compatibility settings. Do not
change them as part of a routine NixOS or package upgrade.

## Secrets

Secrets under `secrets/` are SOPS-encrypted YAML/JSON/dotenv files. The SOPS
module is the local flake in `modules/sops/`; it uses the persistent host SSH
key and exposes the age key at:

```text
/nix/persist/var/lib/sops-nix/key.txt
```

The default SOPS file is `secrets/secrets.yaml`; individual modules reference
additional encrypted files when needed. Never print, decrypt into the repo,
commit plaintext secrets, or expose private WireGuard/SOPS material in logs.
Use `sops edit` and `sops updatekeys` for secret changes. The `.sops.yaml`
contains recipients and is safe to edit only with care because changing them
can make existing secrets undecryptable for a host.

## Common commands

Run these from the repository root (`/etc/nixos`):

```sh
# Evaluate the flake and deploy-rs checks.
nix flake check

# Build/evaluate one system without switching it.
nix build .#nixosConfigurations.main.config.system.build.toplevel
nix build .#nixosConfigurations.netcup.config.system.build.toplevel

# Local activation (choose the local profile deliberately).
sudo nixos-rebuild switch --flake .#main
sudo nixos-rebuild switch --flake .#laptop
sudo nixos-rebuild switch --flake .#wsl

# The configured helper can also be used on installed systems.
nh os switch -H main .

# Remote server deployment through deploy-rs.
nix run github:serokell/deploy-rs -- .#netcup
nix run github:serokell/deploy-rs -- .#orangepi5pro
nix run github:serokell/deploy-rs -- .
```

When changing the service registry, evaluate/build both the gateway and the
affected backend. A registry change can alter nginx, ACME, stream forwarding,
and firewall policy even when no host configuration file changed.

Format touched Nix files with `nixfmt` when available. Keep `flake.lock`
changes intentional: update inputs only when the task calls for it, and review
the resulting lockfile diff.

## Safe change patterns

### Add or modify a host

Update `infra/hosts.nix`, add or update the matching entry in
`modules/profiles.nix`, and add the host configuration/hardware files under
`hosts/<name>/`. A deployed host must have `deploy = true`, `sshHostname`, and
`sshUser`; a gateway/backend host that participates in WireGuard needs the
appropriate `vpnAddress`. Re-run flake checks before deployment.

### Add or modify an exposed service

1. Implement or enable the backend service module.
2. Add its validated declaration to `infra/services.nix`.
3. Check that the backend binds appropriately and that the generated `wg0`
   firewall opening is sufficient.
4. Build/check the backend and gateway, then deploy both deliberately.

### Change network policy

Check all three layers: host-local firewall rules, generated `wg0` rules, and
gateway public forwarding. Avoid broad public binds or public firewall ports
when WireGuard-only access is sufficient.

### Hardware and disk changes

Treat generated `hardware-configuration.nix` files and Disko definitions as
machine-specific. Read the target device and mount layout before changing
them; especially on `orangepi5pro`, `/boot` and the SD-card layout are part of
the boot path.

## Agent expectations

- Read the relevant profile, host file, and infrastructure registry before
  changing a server or networking behavior.
- Prefer declarative module changes over imperative SSH edits.
- Do not assume every imported module is enabled; follow the effective option
  values and `enable` flags.
- Do not silently broaden public exposure, rotate recipients, or change disk
  layout.
- Validate first, then deploy only the hosts affected by the change.
- Preserve unrelated worktree changes and do not regenerate `flake.lock`
  opportunistically.
