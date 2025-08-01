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
in
{
  rockchip-mpp = rockchip-mpp;

  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      rockchip-mpp
      libdrm
    ];
    configureFlags = (old.configureFlags or [ ]) ++ [ "--enable-rkmpp" ];
  });
}
