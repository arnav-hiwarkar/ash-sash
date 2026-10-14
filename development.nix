# System-wide development tools for Python, Rust, C, C++, and AstroNvim.
{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Python interpreter, isolated project environments, testing and debugging.
    (python3.withPackages (
      ps: with ps; [
        pip
        virtualenv
        setuptools
        wheel
        pytest
        debugpy
      ]
    ))
    uv
    ruff
    pyright

    # Rust compiler, package manager, formatting, linting, and language server.
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    # GCC is the default cc/c++ compiler; Clang remains available explicitly.
    gcc
    (lib.lowPrio clang)
    clang-tools
    gdb
    lldb
    cmake
    gnumake
    ninja
    pkg-config

    # Existing AstroNvim tools are also available from ordinary terminals.
    tree-sitter
    lua-language-server
    stylua
    nixd
    nixfmt
    bash-language-server
    shellcheck
    shfmt
    taplo
    lazygit
    openssl
    libclang
    cargo-nextest
    cargo-audit
    cargo-watch
    nodejs
    wl-clipboard
    xclip
  ];

  # Keep standard-library navigation compatible with the packaged Rust compiler.
  environment.variables = {
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
