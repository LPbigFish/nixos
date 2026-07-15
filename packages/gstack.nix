{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  perl,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

# gstack for opencode.
# Builds the compiled browse/design/make-pdf CLIs, generates the opencode skill
# docs (bun run gen:skill-docs --host opencode), and assembles a self-contained
# skills tree at $out/skills/ containing the enriched `gstack` runtime dir plus
# every generated `gstack-*` skill. Wire into ~/.config/opencode/skills (see
# hosts/*/home.nix) by union-merging with the hand-written files/opencode/skills.
#
# ponytail: pin to commit (no release tags upstream); build only for the host
# arch — bun --compile emits a binary for the build platform, cross-compile via
# separate derivation if aarch64 hosts need it.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gstack";
  version = "1.60.1.0";

  src = fetchFromGitHub {
    owner = "garrytan";
    repo = "gstack";
    # No release tags upstream; VERSION file carries the version.
    rev = "a3259400a366593e0c909dd9ac3e59752efd2488";
    hash = "sha256-Zr/pcWscmdi53OMjmY72qJiZLaQ9FKNnyd3dRGX0g5Q=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/node_modules

      runHook postInstall
    '';

    # Required else the FOD references store paths.
    dontFixup = true;
    outputHash = "sha256-c4Mb1XkINWLLpXje04igQ/6atbmEy68GV+DKGmA83gY=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
    perl
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/node_modules ./node_modules
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Vendor xterm into extension/lib (gen:skill-docs references it).
    cp -R node_modules/xterm/lib/xterm.js extension/lib/xterm.js 2>/dev/null || true
    cp -R node_modules/xterm/css/xterm.css extension/lib/xterm.css 2>/dev/null || true
    cp -R node_modules/xterm-addon-fit/lib/xterm-addon-fit.js extension/lib/xterm-addon-fit.js 2>/dev/null || true

    # Generate opencode skill docs -> .opencode/skills/gstack*.
    bun run gen:skill-docs --host opencode

    # Compiled CLIs (bun --compile embeds the runtime, self-contained binaries).
    bun build --compile browse/src/cli.ts --outfile browse/dist/browse
    bun build --compile browse/src/find-browse.ts --outfile browse/dist/find-browse
    bun build --compile design/src/cli.ts --outfile design/dist/design
    bun build --compile make-pdf/src/cli.ts --outfile make-pdf/dist/pdf
    bun build --compile bin/gstack-global-discover.ts --outfile bin/gstack-global-discover

    # Node-compatible server bundle (externalizes playwright/diff/etc).
    bash browse/scripts/build-node-server.sh

    chmod +x browse/dist/browse browse/dist/find-browse design/dist/design make-pdf/dist/pdf bin/gstack-global-discover

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    dest=$out/skills
    mkdir -p "$dest"

    # All generated opencode skills (gstack root + gstack-* siblings).
    cp -R .opencode/skills/gstack "$dest"/
    for d in .opencode/skills/gstack-*; do
      cp -R "$d" "$dest"/
    done

    # Enrich the gstack runtime dir with the binaries + reference assets the
    # skills load at runtime (mirrors create_opencode_runtime_root in setup).
    runtime="$dest/gstack"
    mkdir -p "$runtime"
    cp -R bin "$runtime"/bin
    mkdir -p "$runtime/browse"
    cp -R browse/dist "$runtime/browse"/dist
    cp -R browse/bin "$runtime/browse"/bin 2>/dev/null || true
    mkdir -p "$runtime/design"
    cp -R design/dist "$runtime"/design/dist
    cp ETHOS.md "$runtime"/ETHOS.md
    mkdir -p "$runtime/review"
    cp -R review/specialists "$runtime"/review/specialists 2>/dev/null || true
    cp review/checklist.md review/design-checklist.md review/greptile-triage.md review/TODOS-format.md "$runtime"/review/ 2>/dev/null || true
    mkdir -p "$runtime/qa"
    cp -R qa/templates "$runtime"/qa/templates 2>/dev/null || true
    cp -R qa/references "$runtime"/qa/references 2>/dev/null || true
    mkdir -p "$runtime/plan-devex-review"
    cp plan-devex-review/dx-hall-of-fame.md "$runtime"/plan-devex-review/ 2>/dev/null || true

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "node_modules"
    ];
  };

  meta = {
    description = "Garry Tan's opencode/Claude Code skill stack + headless browser";
    homepage = "https://github.com/garrytan/gstack";
    license = lib.licenses.mit;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # ponytail: bun --compile is build-platform-native; no cross-compile yet.
  };
})
