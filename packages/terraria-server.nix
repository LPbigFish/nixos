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
    sha256 = lib.fakeSha256;
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

    # Copy all game files into a libexec dir
    mkdir -p $out/libexec/terraria-server
    cp -r . $out/libexec/terraria-server/

    # --- IMPORTANT BIT (from the guide) ---
    # Enter the directory and remove the problematic/x86-specific DLLs.
    # This forces mono to use its own system-wide (aarch64) libraries.
    echo "Removing bundled Mono/System libraries..."
    cd $out/libexec/terraria-server
    rm System* Mono* monoconfig mscorlib.dll

    # --- Create the wrapper script ---
    mkdir -p $out/bin
    cat > $out/bin/TerrariaServer << EOF
    #!${runtimeShell}
    # Change to the directory with the game files
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