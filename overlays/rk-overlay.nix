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
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
            runHook preInstall
            mkdir -p "$out/lib" "$out/include" "$out/lib/pkgconfig"

            cp -av include/* "$out/include/"

            cp -av libs/Linux/gcc-aarch64/* "$out/lib/"
            cat > "$out/lib/pkgconfig/librga.pc" <<EOF
      Name: librga
      Description: Rockchip Raster Graphic Accelerator userspace library
      Version: 1.10.0
      Libs: -L$out/lib -lrga
      Cflags: -I$out/include
      EOF

            runHook postInstall
    '';
  };
in
{
  rockchip-mpp = rockchip-mpp;

  librga = librga;

  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      rockchip-mpp
      libdrm
      librga
    ];
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-rkmpp"
      "--enable-rkrga"
    ];
  });
}
