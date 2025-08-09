{ pkgs, extraPkgs ? [], ... }:
let
  inherit (pkgs.lib) getExe;
  toolchain =
    if pkgs ? rust-bin then
      [ pkgs.rust-bin.stable.latest.default ]
    else
      (with pkgs; [
        rustc
        cargo
        clippy
        rustfmt
      ]);
in
pkgs.mkShellNoCC {
  packages =
    toolchain
    ++ (with pkgs; [
      rust-analyzer
      lldb
      sccache
      bacon
      typos
      taplo
      cargo-binstall
      cargo-edit
      cargo-expand
      cargo-nextest
      cargo-outdated
      cargo-audit
      cargo-deny
    ])
    ++ extraPkgs;

  RUSTC_WRAPPER = getExe pkgs.sccache;

  CARGO_INCREMENTAL = "1";
  RUST_BACKTRACE = "1";

  shellHook = ''
    echo "Rust devShell"

    rustc --version; cargo --version; lldb --version | head -n1 || true
  '';
}
