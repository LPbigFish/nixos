```

sudo nix run 'github:nix-community/disko/latest#disko-install' --experimental-features "nix-command flakes" -- --write-efi-boot-entries --flake '/tmp/config/etc/nixos#mymachine' --disk main /dev/nvme0n1

sudo nixos-generate-config --root /tmp/config --no-filesystems --show-hardware-config > hardware-configuration.nix

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix

```