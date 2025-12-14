final: prev: {
  orchis-theme = prev.callPackage ../packages/orchis-theme.nix {};
  terraria-server = prev.callPackage ../packages/terraria-server.nix {};
}