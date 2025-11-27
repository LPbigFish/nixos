{
  description = "Dev shell for Kotlin Multiplatform + Compose (Desktop & Android)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # or your preferred channel
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

        # Native libraries often needed by Compose Desktop / Skiko / AWT on Linux
        composeDesktopLibs = with pkgs; [
          # X11 stack
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libXrandr
          xorg.libXinerama
          xorg.libXcursor
          xorg.libXi
          # Fonts & rendering
          fontconfig
          freetype
          pango
          cairo
          harfbuzz
          # GTK for AWT/Swing (used by tooling)
          gtk3
          gdk-pixbuf
          # Sound & printing
          alsa-lib
          cups
          # OpenGL, GLVND
          libGL
          libglvnd
          # Wayland bits (optional but handy)
          wayland
          # Zstd, zlib (sometimes pulled by tools)
          zstd
          zlib
        ];

        # A reasonably modern Android SDK bundle via androidenv
        android = pkgs.androidenv.composeAndroidPackages {
          # Adjust versions as you like; these are common baselines
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [ "34.0.0" ];
          platformVersions = [ "34" ];
          includeEmulator = true;
          includeSystemImages = false; # set true if you want emulator images in the store
          cmakeVersions = [ "3.22.1" ];
          ndkVersions = [ "26.3.11579264" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              jdk21 # JDK 21 works great with modern Kotlin & Compose
              gradle_8 # Use wrapper in projects, but handy to have
              kotlin-language-server
              android-tools # adb, fastboot, etc.
            ]
            ++ composeDesktopLibs
            ++ [ android.androidsdk ];

          # Useful environment for Gradle/Android tooling
          ANDROID_HOME = "${android.androidsdk}/share/android-sdk";
          ANDROID_SDK_ROOT = "${android.androidsdk}/share/android-sdk";
          JAVA_HOME = pkgs.jdk21;
          # Make native libs easy to find at runtime
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath composeDesktopLibs;

          shellHook = ''
            echo "Kotlin MPP + Compose dev shell"
            echo "JDK:      \$\{JAVA_HOME}"
            echo "Android:  \$\{ANDROID_SDK_ROOT}"
            echo ""
            echo "TIP: Run 'sdkmanager --licenses' once to accept SDK licenses:"
            echo "  yes | \$\{ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses || true"
          '';
        };
      }
    );
}
