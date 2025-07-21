#!/usr/bin/env bash
#
# Lightweight NixOS flake installer — single-shot via disko-install.
#   • Adds 4 GiB compressed zram swap (auto-removed on exit)
#   • Limits Nix to one job to curb peak RAM use
#   • Generates hardware-configuration.nix *without* fileSystems into $PWD
#   • Runs disko-install → partitions, mounts, nixos-install in one go
#
# USAGE
#   sudo ./scripts/install.sh laptop
#     where “laptop” matches an output in your flake (.#laptop)
#
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <host>"
  exit 1
fi
HOST="$1"

echo "### 0 ▶ enabling Nix flakes & capping parallelism"
export NIX_CONFIG="experimental-features = nix-command flakes"
export NIX_BUILD_CORES=1       # no multi-core builds
export NIX_REMOTE=daemon       # use the running nix-daemon

echo "### 0 ▶ adding 4 GiB zram swap to survive big closures"
modprobe zram
echo 4096M > /sys/block/zram0/disksize
mkswap   /dev/zram0
swapon   /dev/zram0
trap 'echo "→ cleaning up zram"; swapoff /dev/zram0 || true' EXIT
echo "     zram swap is active ($(swapon --show --bytes -o SIZE -n) bytes)"

echo "### 1 ▶ generating hardware-configuration.nix (no fileSystems)"
sudo nixos-generate-config --no-filesystems --show-hardware-config \
  | sudo tee ./hardware-configuration.nix >/dev/null
echo "     saved to $(pwd)/hardware-configuration.nix"

echo "### 2 ▶ running disko-install for host «${HOST}»"
nix run github:nix-community/disko --command \
  disko-install --flake ".#${HOST}" \
  --no-root-passwd \
  --max-jobs 1 \
  --option builders "" \
  --option narinfo-cache-negative-ttl 0

echo "✓ Installation complete."
echo "  Reboot when ready — the temporary zram swap will be unloaded automatically."