{
  swapSize ? "8G",
  ...
}:
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1"; # change to your stable path
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ]; # force on reinstall
            subvolumes = {
              "@root" = {
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@persist" = {
                mountpoint = "/nix/persist";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                  "X-mount.mkdir"
                ];
              };
              "@swap" = {
                mountpoint = "/.swapvol";
                swap.swapfile.size = swapSize;
              };
            };
          };
        };
      };
    };
  };
}
