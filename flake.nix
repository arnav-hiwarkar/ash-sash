{
  description = "Sash headless NixOS laptop and personal Git server";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/b25309931cfda5f0b8805f462a29897eeae50168";
  outputs = { self, nixpkgs }: {
    nixosConfigurations.sash = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
    devShells.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          rustfmt
          clippy
          rust-analyzer
          gcc
          clang
          clang-tools
          pkg-config
          openssl
          cmake
          gnumake
          ninja
          gdb
          lldb
        ];
        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
      };
  };
}
