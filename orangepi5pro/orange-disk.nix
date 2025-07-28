{ swapSize ? "8G", ... }:
{
  disko.devices.disk.nvme = {
    type = "disk";
    device = "/dev/by-id/nvme-WD_Blue_SN570_500GB_224014494111"; # change to your stable path
    content = {
      type = "gpt";
      partitions = {
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
