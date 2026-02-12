{ pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "v2202602337123433446";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
  users.users.lpbigfish = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
    initialPassword = "1234567890";
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NyaC1lYDI1NTE5AAAAIMxi1IWl6ruYYblKGbg3LyFi5v8nWftqPpp1fWUDKGEa lpbyblock@gmail.com"
    ];
  };

  users.users.root = {
    initialPassword = "1234567890";
  };

  environment.systemPackages = with pkgs; [
    wget
  ];

  
  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "25.11";

}