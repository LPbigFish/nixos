{
  # Desktop / mobile hosts: metadata only, deployed by their own
  # auto-upgrade, not by deploy-rs.
  wsl.system = "x86_64-linux";
  main.system = "x86_64-linux";
  laptop.system = "x86_64-linux";
  minimal.system = "x86_64-linux";

  netcup = {
    system = "x86_64-linux";
    vpnAddress = "10.100.0.1";
    gateway = true;
    deploy = true;
    sshHostname = "37.120.168.146";
    sshUser = "lpbigfish";
  };

  orangepi5pro = {
    system = "aarch64-linux";
    vpnAddress = "10.100.0.2";
    deploy = true;
    # reached directly over the LAN
    sshHostname = "192.168.18.76";
    sshUser = "lpbigfish";
  };
}
