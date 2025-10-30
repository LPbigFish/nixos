{
  lib,
  stdenv,
  fetchurl,

  # --- Dependencies for aarch64/Mono ---
  unzip,        # To extract the zip
  mono,         # The .NET runtime
  runtimeShell, # For the wrapper script
  libgdiplus,   # For Mono's System.Drawing
  SDL2,         # For FNA (graphics/audio library)
  zlib          # General dependency
}:

stdenv.mkDerivation rec {
  pname = "terraria-server";
  version = "1.4.4.9";
  urlVersion = lib.replaceStrings [ "." ] [ "" ] version;

  src = fetchurl {
    url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${urlVersion}.zip";
    sha256 = "sha256-Mk+5s9OlkyTLXZYVT0+8Qcjy2Sb5uy2hcC8CML0biNY=";
  };

  nativeBuildInputs = [
    unzip
  ];

  # These are runtime dependencies for mono and FNA.dll
  buildInputs = [
    mono
    libgdiplus
    SDL2
    zlib
  ];

  installPhase = ''
    runHook preInstall

    # Create the target dir
    mkdir -p $out/libexec/terraria-server

    # The log says 'source root is 1449'. This means we are INSIDE 1449.
    # We need to copy the *contents* of the 'Linux' subdir.
    cp -r ./Linux/* $out/libexec/terraria-server/

    # --- IMPORTANT BIT (from the guide) ---
    # Now the files are directly in $out/libexec/terraria-server
    echo "Removing bundled Mono/System libraries..."
    cd $out/libexec/terraria-server

    # Use 'rm -f' to ignore "no such file or directory" errors,
    # which is safer for globs and future package updates.
    rm -f System* Mono* monoconfig mscorlib.dll

    # --- Create the wrapper script ---
    mkdir -p $out/bin
    cat > $out/bin/TerrariaServer << EOF
    #!${runtimeShell}
    # Change to the directory with the game files
    # This path is now correct because we copied the contents of 'Linux'
    cd "$out/libexec/terraria-server"

    # Execute using mono with flags from the guide
    # Pass all user-provided arguments ("$@") to the server
    echo "Starting TerrariaServer.exe with Mono..."
    exec ${mono}/bin/mono --server --gc=sgen -O=all ./TerrariaServer.exe "$@"
    EOF

    # Make the wrapper executable
    chmod +x $out/bin/TerrariaServer

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://terraria.org";
    description = "Dedicated server for Terraria (aarch64/Mono version)"; # Updated description
    platforms = [ "aarch64-linux" ]; # <-- The key platform change
    license = licenses.unfree;
    mainProgram = "TerrariaServer";
  };
}