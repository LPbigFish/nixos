{ pkgs, ... }:
let
  inherit (pkgs.lib) getExe;
in
pkgs.mkShell {
  packages = with pkgs; [
      # rust-overlay included
      rust-bin.stable.latest.default
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
    ];

  RUSTC_WRAPPER = getExe pkgs.sccache;

  CARGO_INCREMENTAL = "1";
  RUST_BACKTRACE = "1";

  shellHook = ''
    echo "Rust devShell"

    rustc --version; cargo --version; lldb --version | head -n1 || true
  '';
}
