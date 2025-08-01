final: prev:
let
  inherit (prev) lib stdenv fetchFromGitHub cmake pkg-config libdrm;

  rockchip-mpp = stdenv.mkDerivation rec {
    pname = "rockchip-mpp";
    # Pick a known-good MPP rev; update if you like.
    version = "1.0.9";
    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo  = "mpp";
      rev   = version;
      # First build will tell you the wanted hash; paste it back here.
      sha256 = lib.fakeSha256;
    };

    nativeBuildInputs = [ cmake pkg-config ];
    buildInputs       = [ libdrm ];
    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DRKPLATFORM=ON"
      "-DBUILD_TEST=OFF"
      "-DBUILD_DOC=OFF"
    ];
  };

  librga = stdenv.mkDerivation rec {
    pname = "librga";
    version = "v2.2.0";
    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo  = "rga";
      rev   = version;
      sha256 = lib.fakeSha256;
    };

    nativeBuildInputs = [ cmake pkg-config ];
    buildInputs       = [ libdrm ];
    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_TEST=OFF"
      "-DBUILD_EXAMPLES=OFF"
    ];
  };
in {
  # Expose the libraries (names are your choice)
  rockchip-mpp = rockchip-mpp;
  librga       = librga;

  # Teach jellyfin-ffmpeg to use them
  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ rockchip-mpp librga libdrm pkg-config ];
    configureFlags = (old.configureFlags or []) ++ [
      "--enable-rkmpp"
      "--enable-rkrga"
    ];
  });
}