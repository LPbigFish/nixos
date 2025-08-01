final: prev: {
  rockchip-mpp = prev.stdenv.mkDerivation rec {
    pname = "rockchip-mpp";
    version = "unstable-LOCAL";

    src = prev.fetchFromGitHub {
      owner = "rockchip-linux";
      repo  = "mpp";
      # Use a tag or commit here (e.g. "release" or a specific tag)
      rev    = "release";
      sha256 = prev.lib.fakeSha256;  # build once to get the real hash
    };

    nativeBuildInputs = [ prev.cmake prev.pkg-config ];
    buildInputs       = [ prev.libdrm ];
    cmakeFlags = [
      "-DRKPLATFORM=ON"
      "-DHAVE_DRM=ON"
      "-DBUILD_TEST=OFF"
      "-DBUILD_DOC=OFF"
    ];

    outputs = [ "out" "dev" ];
    postInstall = ''
      # put headers and pkgconfig in dev output
      moveToOutput include $dev
      moveToOutput lib/pkgconfig $dev
    '';

    meta = {
      platforms = [ "aarch64-linux" ];
      description = "Rockchip Media Process Platform (MPP)";
    };
  };
}