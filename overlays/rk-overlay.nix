final: prev:
let
  inherit (prev)
    lib
    stdenv
    stdenvNoCC
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

    librga = stdenvNoCC.mkDerivation rec {
    pname = "librga";
    version = "v1.10.0";
    src = fetchFromGitHub {
      owner = "airockchip";
      repo  = "librga";
      rev   = version;
      sha256 = "sha256-8vDr/Il+Hf72r2fqI2r5K5v6lbnskY5Eb6XY18AYkJA=";
    };

    outputs = [ "out" "dev" ];
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib" "$dev/include" "$dev/lib/pkgconfig"

      # headers + libs
      cp -av include/*.h "$dev/include/"
      cp -av libs/Linux/gcc-aarch64/librga.* "$out/lib/" 2>/dev/null || true

      # Some consumers expect <rga/...>
      mkdir -p "$dev/include/rga"
      for h in "$dev"/include/*.h; do
        ln -s ../"$(basename "$h")" "$dev/include/rga/$(basename "$h")"
      done

      ver="1.10.0"
      for name in librga rga; do
        cat > "$dev/lib/pkgconfig/$name.pc" <<EOF
prefix=/dummy
exec_prefix=\$prefix
libdir=/dummy/lib
includedir=/dummy/include

Name: $name
Description: Rockchip Raster Graphic Accelerator userspace library
Version: $ver
Libs: -L\$libdir -lrga
Cflags: -I\$includedir -I\$includedir/rga
EOF
      done
      runHook postInstall
    '';

    # Regex-fix like mpp: set real prefix/libdir/includedir
    postFixup = ''
      shopt -s nullglob
      for pc in "$dev"/lib/pkgconfig/*.pc; do
        sed -E -i \
          -e 's|^prefix=.*|prefix='"$out"'|' \
          -e 's|^libdir=.*|libdir='"$out"'/lib|' \
          -e 's|^includedir=.*|includedir='"$dev"'/include|' \
          "$pc"
      done
    '';

    meta.platforms = lib.platforms.aarch64;
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
      export PKG_CONFIG_PATH=${librga.dev}/lib/pkgconfig:${rockchip-mpp}/lib/pkgconfig:$PKG_CONFIG_PATH
      echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
      pkg-config --exists librga && echo "librga ok $(pkg-config --modversion librga)" || { echo "librga missing"; ls -l ${librga.dev}/lib/pkgconfig; }
    '';
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-rkmpp"
      "--enable-rkrga"
    ];
  });
}
