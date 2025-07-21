#!/usr/bin/env bash
#
# RAM-friendly NixOS flake installer via disko-install (latest).
#
# Features
#   • Adds 4 GiB compressed zram swap (auto-cleanup on exit)
#   • Limits Nix to one build job
#   • Generates hardware-configuration.nix *without* fileSystems into $PWD
#   • Runs disko-install (partition + mount + nixos-install) in one go
#   • Optional --disk <device-path> to override the device used for the disko "main" disk
#   • Optional --disk-name <name> if your disko layout uses a name other than "main"
#
# Usage:
#   sudo ./scripts/install.sh <host> [--disk /dev/sda] [--disk-name main]
#
# Examples:
#   sudo ./scripts/install.sh mymachine --disk /dev/sda
#   sudo ./scripts/install.sh mymachine --disk-name nvme --disk /dev/nvme0n1
#
set -euo pipefail

#----- arg parse --------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo $0 ...)."
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <host> [--disk /dev/xxx] [--disk-name main]"
  exit 1
fi

HOST="$1"; shift

DISK_PATH=""
DISK_NAME="main"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk)
      shift
      [[ $# -gt 0 ]] || { echo "--disk needs a path"; exit 1; }
      DISK_PATH="$1"; shift
      ;;
    --disk-name)
      shift
      [[ $# -gt 0 ]] || { echo "--disk-name needs a value"; exit 1; }
      DISK_NAME="$1"; shift
      ;;
    *)
      echo "unknown arg: $1"
      exit 1
      ;;
  esac
done

# Build the --disk args array (only if user supplied a path)
DISK_ARGS=()
if [[ -n "$DISK_PATH" ]]; then
  DISK_ARGS=(--disk "$DISK_NAME" "$DISK_PATH")
fi

echo "### Host: $HOST"
if [[ -n "$DISK_PATH" ]]; then
  echo "### Device override: $DISK_NAME → $DISK_PATH"
else
  echo "### Using disk paths from flake disko config (no override)."
fi

#----- nix settings -----------------------------------------------------------
echo "### Enabling flakes & throttling builds"
export NIX_CONFIG="experimental-features = nix-command flakes"
export NIX_BUILD_CORES=1
export NIX_REMOTE=daemon

#----- zram swap --------------------------------------------------------------
echo "### Adding 4 GiB zram swap"
modprobe zram
echo 4096M > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon /dev/zram0
trap 'echo "→ cleaning up zram"; swapoff /dev/zram0 || true' EXIT
echo "    zram active: $(swapon --show --bytes -o NAME,SIZE | grep zram0 || true)"

#----- hardware config --------------------------------------------------------
echo "### Generating hardware-configuration.nix (no fileSystems) into CWD"
nixos-generate-config --no-filesystems --show-hardware-config \
  > ./hardware-configuration.nix
echo "    saved: $(pwd)/hardware-configuration.nix"

#----- install (all-in-one) ---------------------------------------------------
echo "### Running disko-install (partition + mount + nixos-install)"
# NOTE: we quote the flake as you did; using $PWD ensures local flake path.
# If you prefer remote (github:...) just change the string below.
nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake ".#${HOST}" \
  "${DISK_ARGS[@]}" \
  --no-root-passwd \
  --max-jobs 1 \
  --option builders "" \
  --option narinfo-cache-negative-ttl 0

echo "✓ Installation complete."
echo "  Reboot when ready; zram swap will be turned off automatically."