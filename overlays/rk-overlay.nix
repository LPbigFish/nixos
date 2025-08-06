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
      sha256 = "sha256-hhvziSG7U9Pte59E860dOm78SjVBzMgHPs2zZNH77qk=";
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
      "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"
      "-DCMAKE_INSTALL_FULL_INCLUDEDIR=${placeholder "out"}/include"
      "-DCMAKE_INSTALL_FULL_LIBDIR=${placeholder "out"}/lib"
    ];

    installPhase = ''
      make install DESTDIR=$out
    '';

    postInstall = ''
        mkdir -p $out/lib/pkgconfig

        cat > $out/lib/pkgconfig/rockchip_mpp.pc <<EOF
      prefix=$out
      exec_prefix=\$""{prefix}
      libdir=\$""{exec_prefix}/lib
      includedir=\$""{prefix}/include

      Name: rockchip_mpp
      Description: Rockchip MPP Library
      Version: 1.0.8
      Libs: -L\$""{libdir} -lrockchip_mpp
      Cflags: -I\$""{includedir}
      EOF
    '';

    postFixup = ''
      echo "Fixing .pc files to remove accidental // in paths..."
      for pc in $out/lib/pkgconfig/*.pc; do
        sed -i 's|'$'"{prefix}//|'$'"{prefix}/|g' "$pc"
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
      "--enable-gpl"
      "--enable-version3"
      "--enable-libdrm"
      "--enable-rkmpp"
      "--enable-rkrga"
      "PKG_CONFIG_PATH=${rockchip-mpp}/lib/pkgconfig"
    ];

    postInstall = ''
      echo "Testing build..."
      $out/bin/ffmpeg -decoders | grep rkmpp || true
      $out/bin/ffmpeg -encoders | grep rkmpp || true
      $out/bin/ffmpeg -filter | grep rkrga || true
    '';
  });
}
