final: prev:
let
  inherit (prev)
    lib
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
      "-Dlibdrm=false"
      "-Dlibrga_demo=false"
    ];

    doCheck = false;
  };

  rockchip-mpp = stdenv.mkDerivation {
    pname = "rockchip-mpp";
    version = "jellyfin-mpp";
    src = fetchFromGitHub {
      owner = "nyanmisaka";
      repo = "mpp";
      rev = "fda5a02e8f88e79ef110e7912c20326a1fea51fb";
      sha256 = lib.fakeSha256;
    };

    nativeBuildInputs = [
      librga
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
in
{
  rockchip-mpp = rockchip-mpp;

  librga = librga;

  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    version = "1.0.0";

    src = final.fetchFromGitHub {
      owner = "nyanmisaka";
      repo = "ffmpeg-rockchip";
      rev = "e2bbfe4b31fc5328a625e266344a0bf3c2c45f60";
      sha256 = "sha256-p+NNcZdYAgZvw0GZrOGKW4wocwPQBjlD7kHbb+59zi0=";
    };

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
