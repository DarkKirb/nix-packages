{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:DarkKirb/flake-utils";
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
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
    hydra,
    ...
  }:
    flake-utils.lib.eachSystem ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" "riscv64-linux"] (
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
              akkoma
              akkoma-fe
              admin-fe
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
              mautrix-signal
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
              plover-dict-didoesdigital
              miifox-net
              old-homepage
              python-instagram
              element-web
              mautrix-cleanup
              woodpecker-agent
              woodpecker-cli
              woodpecker-frontend
              woodpecker-server
              wordpress-plugins
              wordpress-themes
              kubo
              hydra
              hydra-unstable
              plover-plugin-python-dictionary
              plover-plugin-stenotype-extended
              asar
              bsnes-plus
              ;
          }
          // (
            if system == "riscv64-linux"
            then {
              inherit (pkgs) vf2Kernel valgrind;
            }
            else {}
          )
          // (
            if system == "x86_64-linux"
            then {
              inherit (pkgs) linux-bcachefs bcachefs-tools;
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
