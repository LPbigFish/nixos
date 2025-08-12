{
  description = "Rust dev flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      lib,
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
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

          RUSTC_WRAPPER = lib.getExe pkgs.sccache;

          CARGO_INCREMENTAL = "1";
          RUST_BACKTRACE = "1";
        };
      }
    );
}
