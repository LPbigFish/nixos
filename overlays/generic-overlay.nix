final: prev: {
  orchis-theme = prev.callPackage ../packages/orchis-theme.nix {};
  terraria-server = prev.callPackage ../packages/terraria-server.nix {};
  orca-slicer = prev.orca-slicer.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/orca-slicer \
          --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
          --set GDK_BACKEND x11 \
          --set LC_ALL C
      '';
    });
}