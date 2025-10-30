{ lib
, stdenv
, fetchurl
, unzip

, mono
, libgdiplus
, SDL2
, openal
, faudio
, libogg
, libvorbis
, libpng
, libjpeg
, zlib
, runtimeShell
}:

stdenv.mkDerivation rec {
  pname = "terraria-server";
  version = "1.4.4.9";
  urlVersion = lib.replaceStrings [ "." ] [ "" ] version;

  src = fetchurl {
    url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${urlVersion}.zip";
    # same hash you used:
    sha256 = "sha256-Mk+5s9OlkyTLXZYVT0+8Qcjy2Sb5uy2hcC8CML0biNY=";
  };

  # We only need unzip at build time
  nativeBuildInputs = [ unzip ];

  # Runtime deps for Mono & native libs FNA may touch
  buildInputs = [
    mono
    libgdiplus
    SDL2
    openal
    faudio
    libogg
    libvorbis
    libpng
    libjpeg
    zlib
  ];

  # No configure/build phases
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/terraria-server
    # upstream puts content in ./Linux
    cp -r Linux/* $out/libexec/terraria-server/

    cd $out/libexec/terraria-server

    # Toss the vendor x86_64 native libs and vendor .NET framework DLLs
    rm -rf lib64
    rm -f System*.dll Mono*.dll monoconfig monomachineconfig mscorlib.dll WindowsBase.dll

    # Make sure the Mono launcher script exists only for reference; we run the .exe
    chmod -f +x TerrariaServer || true
    chmod -f +x TerrariaServer.bin.x86_64 || true

    # Create wrapper
    mkdir -p $out/bin
    cat > $out/bin/TerrariaServer <<EOF
    #!${runtimeShell}
    set -euo pipefail
    cd "$out/libexec/terraria-server"

    # Native libs path (keep order simple; add more if you see missing .so’s)
    export LD_LIBRARY_PATH="${SDL2}/lib:${openal}/lib:${faudio}/lib:${libvorbis}/lib:${libogg}/lib:${libpng}/lib:${libjpeg}/lib:${zlib}/lib''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"


    # If you want more Mono verbosity for debugging, uncomment:
    # export MONO_LOG_LEVEL=info

    exec ${mono}/bin/mono --server --gc=sgen -O=all ./TerrariaServer.exe "\$@"
    EOF
    chmod +x $out/bin/TerrariaServer

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dedicated server for Terraria (runs with Mono on aarch64)";
    homepage = "https://terraria.org";
    license = licenses.unfree;
    platforms = [ "aarch64-linux" ];
    mainProgram = "TerrariaServer";
  };
}
