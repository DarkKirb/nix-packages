{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:DarkKirb/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat/4f910c9827911b1ec2bf26b5a062cd09f8d89f85";
      flake = false;
    };
    mautrix-cleanup = {
      url = "github:DarkKirb/mautrix-cleanup";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    gomod2nix = {
      url = "github:DarkKirb/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    hydra = {
      url = "git+https://git.chir.rs/darkkirb/hydra";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachSystem ["aarch64-linux" "x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
          overlays = [
            self.overlays.${system}.default
          ];
        };
      in rec {
        formatter = pkgs.alejandra;

        overlays.default = import ./overlay.nix system;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
            nix-prefetch
          ];
        };

        packages =
          {
            inherit
              (pkgs)
              emoji-lotte
              emoji-volpeon-blobfox
              emoji-volpeon-blobfox-flip
              emoji-volpeon-bunhd
              emoji-volpeon-bunhd-flip
              emoji-volpeon-drgn
              emoji-volpeon-fox
              emoji-volpeon-gphn
              emoji-volpeon-raccoon
              emoji-volpeon-vlpn
              emoji-volpeon-neofox
              emoji-volpeon-neocat
              emoji-caro
              lotte-art
              alco-sans
              constructium
              fairfax
              fairfax-hd
              kreative-square
              nasin-nanpa
              matrix-media-repo
              mautrix-discord
              mautrix-whatsapp
              mautrix-telegram
              python-mautrix
              python-tulir-telethon
              papermc
              python-plover-stroke
              python-rtf-tokenize
              plover
              plover-plugins-manager
              python-simplefuzzyset
              plover-plugin-emoji
              plover-plugin-tapey-tape
              plover-plugin-yaml-dictionary
              plover-plugin-machine-hid
              plover-plugin-rkb1-hid
              plover-plugin-dotool-output
              plover-dict-didoesdigital
              miifox-net
              old-homepage
              python-instagram
              mautrix-cleanup
              kubo
              hydra
              hydra-unstable
              plover-plugin-python-dictionary
              plover-plugin-stenotype-extended
              asar-asm
              bsnes-plus
              sliding-sync
              go-ds-s3
              ;
          }
          // (
            if system == "riscv64-linux"
            then {
              inherit (pkgs) vf2Kernel valgrind;
            }
            else {}
          );

        modules = import ./modules;
        lib = import ./lib {inherit pkgs;};

        hydraJobs = {
          inherit packages devShells formatter;
        };
      }
    );
}
