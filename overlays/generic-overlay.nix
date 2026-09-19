final: prev: {
  orchis-theme = prev.callPackage ../packages/orchis-theme.nix { };
  resolve-convert = prev.callPackage ../packages/resolve-convert.nix { };
  terraria-server = prev.callPackage ../packages/terraria-server.nix { };
  gstack = prev.callPackage ../packages/gstack.nix { };
  opencode = prev.callPackage ../packages/opencode-1.18.29.nix { };
}
