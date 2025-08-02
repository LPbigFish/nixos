final: prev:
let
  inherit (prev)
    lib
    stdenv
    fetchFromGitHub
    cmake
    ninja
    pkg-config
    libdrm
    ;

  rockchip-mpp = stdenv.mkDerivation rec {
    pname = "rockchip-mpp";
    version = "1.0.9";
    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "mpp";
      rev = version; # note: no leading 'v'
      sha256 = "sha256-+1Gnx7n9nZVVt0S/hZEzXupADPX0JRmTGD1XBhLMZ7o=";
    };

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
    ];
    buildInputs = [ libdrm ];

    cmakeFlags = [
      "-DRKPLATFORM=ON"
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_INSTALL_LIBDIR=lib"
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
    ];

    # Fix double-slash paths in the generated .pc files
    postFixup = ''
      shopt -s nullglob
      for pc in "$out"/lib/pkgconfig/*.pc; do
        sed -i \
          -e 's|^libdir=.*|libdir='"$out"'/lib|' \
          -e 's|^includedir=.*|includedir='"$out"'/include|' \
          "$pc"
      done
    '';
  };

  librga = stdenv.mkDerivation rec {
    pname = "librga";
    version = "v1.10.0"; # or another stable tag
    src = fetchFromGitHub {
      owner = "airockchip";
      repo = "librga";
      rev = version;
      sha256 = "sha256-8vDr/Il+Hf72r2fqI2r5K5v6lbnskY5Eb6XY18AYkJA="; # replace after first build
    };
    outputs = [
      "out"
      "dev"
    ];
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
          runHook preInstall
          mkdir -p "$out/lib" "$dev/include" "$dev/lib/pkgconfig"

          cp -av include/* "$dev/include/"
          cp -av libs/Linux/gcc-aarch64/* "$out/lib/"

          for pc in librga rga; do
            cat > "$dev/lib/pkgconfig/$pc.pc" <<EOF
      Name: $pc
      Description: Rockchip Raster Graphic Accelerator userspace library
      Version: ${version}
      Libs: -L$out/lib -lrga
      Cflags: -I$dev/include
      EOF
          done
          runHook postInstall
    '';
    meta.platforms = [ "aarch64-linux" ];
  };
in
{
  rockchip-mpp = rockchip-mpp;

  librga = librga;

  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      librga
      libdrm
      rockchip-mpp
    ];
    preConfigure = (old.preConfigure or "") + ''
      export PKG_CONFIG_PATH=${librga.dev}/lib/pkgconfig:${rockchip-mpp.dev}/lib/pkgconfig:$PKG_CONFIG_PATH
      echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
      pkg-config --exists librga && echo "librga ok $(pkg-config --modversion librga)" || { echo "librga missing"; ls -l ${librga.dev}/lib/pkgconfig; }
    '';
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-rkmpp"
      "--enable-rkrga"
    ];
  });
}
