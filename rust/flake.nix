{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ flake-parts, nixpkgs, rust-overlay, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { system, ... }:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };

          rustToolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "rust-analyzer"
              "clippy"
            ];
          };

          devTools = with pkgs; [
            # Core Rust toolchain
            rustToolchain

            # Build tools
            cargo-watch          # Watch for changes and run commands
            cargo-nextest        # Next-gen test runner
            cargo-audit          # Vulnerability auditing
            cargo-deny           # License/dependency checker
            cargo-outdated       # Check for outdated dependencies
            cargo-edit           # Add/remove/upgrade deps from CLI
            cargo-expand         # Expand macros
            cargo-tarpaulin      # Code coverage
            cargo-bloat          # Binary size analyzer
            cargo-generate       # Project templating

            # Formatters & linters
            rustfmt              # Official formatter (bundled, but explicit)
            bacon                # Background code checker

            # Cross-compilation & WASM
            # wasm-pack          # Rust → WASM (uncomment if needed)

            # Database (optional — uncomment as needed)
            postgresql

            # General dev tools
            pkg-config
            openssl
            git
            just                 # Command runner

            # For crates with C dependencies
            gcc
            cmake
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            name = "rust-dev";

            packages = devTools;

            shellHook = ''
              trap 'pg_ctl stop; echo "PostgreSQL process stopped!"' EXIT

              export PGDATA="$PWD/data/pgdata"

              if [ ! -d "$PGDATA" ]; then
                echo "Creating PostgreSQL data directory in $PGDATA"
                initdb -D $PGDATA --no-locale --encoding=UTF8
              else
                echo "To run PostgreSQL run:"
                echo "pg_ctl -D $PGDATA -l ./data/log_file start"
              fi

              export RUST_BACKTRACE=1
              export RUST_LOG=debug

              echo ""
              figlet "rust-dev" 2>/dev/null || echo "🦀 Rust development environment"
              echo ""
              echo "Toolchain:"
              echo "  rustc     $(rustc --version)"
              echo "  cargo     $(cargo --version)"
              echo "  clippy    $(cargo clippy --version 2>/dev/null || echo 'ready')"
              echo "  rustfmt   $(rustfmt --version)"
              echo ""
              echo "Available tools:"
              echo "  cargo-watch, cargo-nextest, cargo-audit, cargo-deny"
              echo "  cargo-outdated, cargo-edit, cargo-expand"
              echo "  cargo-tarpaulin, cargo-bloat, cargo-generate"
              echo "  bacon, just, git, postgresql"
              echo ""
              echo "Quick start:"
              echo "  cargo init    - Create a new project"
              echo "  bacon          - Continuous code checking"
              echo "  just           - Run project tasks (see justfile)"
            '';

            # Environment variables
            RUST_BACKTRACE = "1";
          };
        };
    };
}
