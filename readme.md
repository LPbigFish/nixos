```

sudo nix run 'github:nix-community/disko/latest#disko-install' --experimental-features "nix-command flakes" -- --flake '/tmp/config/etc/nixos#mymachine' --disk main /dev/sda


sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix

```