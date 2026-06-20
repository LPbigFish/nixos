final: prev: {
  orchis-theme = prev.callPackage ../packages/orchis-theme.nix { };
  resolve-convert = prev.callPackage ../packages/resolve-convert.nix { };
  terraria-server = prev.callPackage ../packages/terraria-server.nix { };
  davinci-resolve-studio = prev.davinci-resolve-studio.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      echo "Applying binary patch..."
      perl -pi -e 's/\x74\x11\xe8\x21\x23\x00\x00/\xeb\x11\xe8\x21\x23\x00\x00/g' $out/bin/resolve
    '';
  });
}
