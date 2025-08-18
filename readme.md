### SOPS SETUP

```
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C <email>

sudo ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub # Write to the .sops.yaml on primary machine

sops updatekeys secrets/secrets.yaml
```

### Normal system

```

sudo nix run 'github:nix-community/disko/latest#disko-install' --experimental-features "nix-command flakes" -- --write-efi-boot-entries --flake '/tmp/config/etc/nixos#mymachine' --disk main /dev/nvme0n1

sudo nixos-generate-config --root /tmp/config --no-filesystems --show-hardware-config > hardware-configuration.nix

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix

```

### Orange Pi 5 Pro
```
sudo apt update
sudo apt install -y curl xz-utils

sh <(curl -L https://nixos.org/nix/install) --daemon

sudo -i
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --version
```
```
# Disko only (partition/format/mount to /mnt)
nix run github:nix-community/disko#disko -- \
  --mode destroy,format,mount \
  ./orangepi5pro/orange-disk.nix

# Mount SD as /mnt/boot (SD is /dev/mmcblk1p1)
mkdir -p /mnt/boot
mount /dev/mmcblk1p1 /mnt/boot

# Install NixOS from the flake
nix shell nixpkgs#nixos-install-tools -c nixos-install --root /mnt --flake .#opi5pro
```
If activation fails:
```
nix shell nixpkgs#nixos-install-tools -c nixos-enter --root /mnt

# Inside chroot, run activation with util-linux so 'mount' exists
nix shell nixpkgs#util-linux -c /nix/var/nix/profiles/system/bin/switch-to-configuration boot
exit
```
Verification:
```
# extlinux.conf present?
test -f /mnt/boot/extlinux/extlinux.conf && echo "extlinux.conf found" || echo "missing"

# Show the three paths referenced (LINUX, INITRD, FDT)
grep -E '^(  LINUX|  INITRD|  FDT)' /mnt/boot/extlinux/extlinux.conf

# Resolve them to real files under /boot/nixos/...
while read -r _ p; do realpath -e "/mnt/boot/extlinux/$p"; done \
  < <(grep -E '^(  LINUX|  INITRD|  FDT)' /mnt/boot/extlinux/extlinux.conf)
```
After boot verification:
```
mount | egrep ' / | /boot '
uname -a
cat /etc/os-release
```