final: prev: {
  orchis-theme = prev.callPackage ../packages/orchis-theme.nix { };
  resolve-convert = prev.callPackage ../packages/resolve-convert.nix { };
  terraria-server = prev.callPackage ../packages/terraria-server.nix { };
  gstack = prev.callPackage ../packages/gstack.nix { };
  opencode = prev.callPackage ../packages/opencode-1.18.29.nix { };
  vscode = prev.vscode.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      chmod +x "$out/lib/vscode/resources/app/node_modules.asar.unpacked/@github/copilot-sdk-linux-x64/prebuilds/linux-x64/copilot-runtime"
    '';
  });
}
