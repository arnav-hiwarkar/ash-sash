{
  description = "Sash headless NixOS laptop and personal Git server";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/b25309931cfda5f0b8805f462a29897eeae50168";
  inputs.opencode = {
    url = "github:anomalyco/opencode/v1.19.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      opencode,
    }:
    {
      nixosConfigurations.sash = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          {
            nixpkgs.overlays = [
              opencode.overlays.default
              (
                final: prev: {
                  opencode = prev.opencode.overrideAttrs (old: {
                    version = "1.19.0";
                    __intentionallyOverridingVersion = true;
                    env = old.env // {
                      OPENCODE_VERSION = "1.19.0";
                    };
                  });
                }
              )
            ];
          }
        ];
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
