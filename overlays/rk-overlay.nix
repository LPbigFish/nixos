final: prev:
let
  inherit (prev)
    gcc
    stdenv
    fetchFromGitHub
    cmake
    meson
    ninja
    pkg-config
    libdrm
    yasm
    nasm
    ;
  librga = stdenv.mkDerivation {
    pname = "librga";
    version = "jellyfin-rga";
    src = fetchFromGitHub {
      owner = "nyanmisaka";
      repo = "rk-mirrors";
      rev = "571a880951583a3b2a04e7e1fa900861653befde";
      sha256 = "sha256-W7P/mRgunDdYeFVUXn0qWN+ExKlZ2eAtPcT0sGFa+1Q=";
    };

    nativeBuildInputs = [
      gcc
      libdrm
      meson
      ninja
      pkg-config
    ];

    mesonBuildDir = "build";

    mesonFlags = [
      "--libdir=lib"
      "--buildtype=release"
      "--default-library=shared"
      "-Dcpp_args=-fpermissive"
      "-Dlibdrm=true"
      "-Dlibrga_demo=false"
    ];

    doCheck = false;
  };

  rockchip-mpp = stdenv.mkDerivation {
    pname = "rockchip-mpp";
    version = "1.0.9";
    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "mpp";
      rev = "ab796560522c767b610ef1ef7930a73d2f8c77eb";
      sha256 = "sha256-y1vWGz7VjwL02klPQWwoIh5ExpvS/vsDUHcMtMznVcI=";
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
in
{
  rockchip-mpp = rockchip-mpp;

  librga = librga;

  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      pkg-config
      yasm
      nasm
    ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      librga
      libdrm
      rockchip-mpp
    ];

    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-rkmpp"
      "--enable-rkrga"
    ];

    preConfigure = (old.preConfigure or "") + ''
      export PKG_CONFIG_PATH=${rockchip-mpp}/lib/pkgconfig:$PKG_CONFIG_PATH
      echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
    '';

    postInstall = ''
      echo "Testing build..."
      $out/bin/ffmpeg -decoders | grep rkmpp || true
      $out/bin/ffmpeg -encoders | grep rkmpp || true
      $out/bin/ffmpeg -filter | grep rkrga || true
    '';
  });
}
