{
  description = "Sash headless NixOS laptop and personal Git server";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/b25309931cfda5f0b8805f462a29897eeae50168";
  inputs.opencode = {
    url = "github:anomalyco/opencode/v1.19.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.pstack-skills = {
    url = "github:backnotprop/pstack/1f0f9c3bac03c4297f6fc8f7644fa412eda57085";
    flake = false;
  };
  inputs.superpowers-skills = {
    url = "github:obra/superpowers/bb92a77741419a4ab5f06e711a283343f1ada0c3";
    flake = false;
  };
  inputs.matt-pocock-skills = {
    url = "github:mattpocock/skills/49dd158d1076134a641b33efb035946536778336";
    flake = false;
  };
  outputs =
    {
      self,
      nixpkgs,
      opencode,
      home-manager,
      pstack-skills,
      superpowers-skills,
      matt-pocock-skills,
    }:
    {
      nixosConfigurations.sash = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit pstack-skills superpowers-skills matt-pocock-skills;
            };
            home-manager.users.ash = import ./home-manager/ash.nix;
          }
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
