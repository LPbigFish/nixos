final: prev:
let
  inherit (prev)
    lib
    stdenv
    stdenvNoCC
    fetchFromGitHub
    cmake
    meson
    ninja
    pkg-config
    libdrm
    yasm
    nasm
    ;

  rockchip-mpp = stdenv.mkDerivation {
    pname = "rockchip-mpp";
    version = "jellyfin-mpp";
    src = fetchFromGitHub {
      owner = "nyanmisaka";
      repo = "mpp";
      rev = "e5f505a21907a485038870b6d9a6bec97cfceaf3";
      sha256 = "sha256-W7P/mRgunDdYeFVUXn0qWN+ExKlZ2eAtPcT0sGFa+1Q=";
    };

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_SHARED_LIBS=ON"
      "-DBUILD_TEST=OFF"
      "-DBUILD_DEMO=OFF"
      "-DBUILD_SAMPLES=OFF"
    ];

    installPhase = ''
      make install DESTDIR=$out
    '';
  };

    librga = stdenvNoCC.mkDerivation {
    pname = "librga";
    version = "jellyfin-rga";
    src = fetchFromGitHub {
      owner = "nyanmisaka";
      repo  = "rk-mirrors";
      rev   = "571a880951583a3b2a04e7e1fa900861653befde";
      sha256 = lib.fakeSha256;
    };

    nativeBuildInputs = [ meson ninja pkg-config ];

    mesonFlags = [
      "--libdir=lib"
      "--buildtype=release"
      "--default-library=shared"
      "--Dcpp_args=-fpermissive"
      "--Dlibdrm=false"
      "--Dlibrga_demo=false"
    ];

    builPhase = "ninja -C build";

    installPhase = "ninja -C build install DESTDIR=$out";
  };
in
{
  rockchip-mpp = rockchip-mpp;

  librga = librga;

  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    version = "1.0.0";

    src = final.fetchFromGitHub {
      owner = "nyanmikasa";
      repo = "ffmpeg-rockchip";
      rev = "e2bbfe4b31fc5328a625e266344a0bf3c2c45f60";
      sha256 = lib.fakeSha256;
    };

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkg-config yasm nasm ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      librga
      libdrm
      rockchip-mpp
    ];

    configureFlags = (old.configureFlags or [ ]) ++ [
      "--enable-gpl"
      "--enable-version3"
      "--enable-libdrm"
      "--enable-rkmpp"
      "--enable-rkrga"
    ];

    postInstall = ''
      echo "Testing build..."
      $out/bin/ffmpeg -decoders | grep rkmpp || true
      $out/bin/ffmpeg -encoders | grep rkmpp || true
      $out/bin/ffmpeg -filter | grep rkrga || true
    '';
  });
}
