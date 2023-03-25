{
  description = "Lotte’s nix packages";

  inputs = {
    cargo2nix = {
      url = "github:DarkKirb/cargo2nix/release-0.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    flake-utils.url = "github:DarkKirb/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    mautrix-cleanup = {
      url = "github:DarkKirb/mautrix-cleanup";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs.url = "github:NixOS/nixpkgs";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" "riscv64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
          overlays = [inputs.cargo2nix.overlays.default];
        };
        inherit (pkgs) lib;
      in rec {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
            nix-prefetch
          ];
        };

        packages =
          {
            akkoma = pkgs.callPackage ./akkoma {};
            pleroma-fe = pkgs.callPackage ./akkoma/pleroma-fe {};
            admin-fe = pkgs.callPackage ./akkoma/admin-fe {};
            emoji-lotte = pkgs.callPackage ./art/emoji/lotte {};
            emoji-volpeon-blobfox = pkgs.callPackage ./art/emoji/volpeon/blobfox.nix {};
            emoji-volpeon-blobfox-flip = pkgs.callPackage ./art/emoji/volpeon/blobfox_flip.nix {};
            emoji-volpeon-bunhd = pkgs.callPackage ./art/emoji/volpeon/bunhd.nix {};
            emoji-volpeon-bunhd-flip = pkgs.callPackage ./art/emoji/volpeon/bunhd_flip.nix {};
            emoji-volpeon-drgn = pkgs.callPackage ./art/emoji/volpeon/drgn.nix {};
            emoji-volpeon-fox = pkgs.callPackage ./art/emoji/volpeon/fox.nix {};
            emoji-volpeon-gphn = pkgs.callPackage ./art/emoji/volpeon/gphn.nix {};
            emoji-volpeon-raccoon = pkgs.callPackage ./art/emoji/volpeon/raccoon.nix {};
            emoji-volpeon-vlpn = pkgs.callPackage ./art/emoji/volpeon/vlpn.nix {};
            emoji-caro = pkgs.callPackage ./art/emoji/caro {};
            lotte-art = pkgs.callPackage ./art/lotte {};
            drone-runner-docker = pkgs.callPackage ./ci/drone-runner-docker {};
            alco-sans = pkgs.callPackage ./fonts/kreative/alco-sans.nix {};
            constructium = pkgs.callPackage ./fonts/kreative/constructium.nix {};
            fairfax = pkgs.callPackage ./fonts/kreative/fairfax.nix {};
            fairfax-hd = pkgs.callPackage ./fonts/kreative/fairfax-hd.nix {};
            kreative-square = pkgs.callPackage ./fonts/kreative/kreative-square.nix {};
            nasin-nanpa = pkgs.callPackage ./fonts/nasin-nanpa {};
            matrix-media-repo = pkgs.callPackage ./matrix/matrix-media-repo {};
            mautrix-discord = pkgs.callPackage ./matrix/mautrix-discord {};
            mautrix-whatsapp = pkgs.callPackage ./matrix/mautrix-whatsapp {};
            mautrix-signal = pkgs.callPackage ./matrix/mautrix-signal {};
            mautrix-telegram = pkgs.callPackage ./matrix/mautrix-telegram {};
            python-mautrix = pkgs.python3Packages.callPackage ./python/mautrix.nix {};
            python-tulir-telethon = pkgs.python3Packages.callPackage ./python/tulir-telethon.nix {};
            papermc = pkgs.callPackage ./minecraft/papermc {};
            python-plover-stroke = pkgs.python3Packages.callPackage ./plover/plover-stroke.nix {};
            python-rtf-tokenize = pkgs.python3Packages.callPackage ./python/rtf-tokenize.nix {};
            plover = pkgs.python3Packages.callPackage ./plover/plover {};
            plover-plugins-manager = pkgs.python3Packages.callPackage ./plover/plover-plugins-manager.nix {};
            python-simplefuzzyset = pkgs.python3Packages.callPackage ./python/simplefuzzyset.nix {};
            plover-plugin-emoji = pkgs.python3Packages.callPackage ./plover/plover-emoji.nix {};
            plover-plugin-tapey-tape = pkgs.python3Packages.callPackage ./plover/plover-tapey-tape.nix {};
            plover-plugin-yaml-dictionary = pkgs.python3Packages.callPackage ./plover/plover-yaml-dictionary.nix {};
            plover-plugin-machine-hid = pkgs.python3Packages.callPackage ./plover/plover-machine-hid.nix {};
            plover-plugin-rkb1-hid = pkgs.python3Packages.callPackage ./plover/plover-rkb1-hid.nix {};
            plover-dict-didoesdigital = pkgs.callPackage ./plover/didoesdigital-dictionary.nix {};
            miifox-net = pkgs.python3Packages.callPackage ./web/miifox-net.nix {};
            old-homepage = pkgs.callPackage ./web/old-homepage.nix {};
            python-instagram = pkgs.python3Packages.callPackage ./python/instagram.nix {};
            attic-client = pkgs.callPackage ./attic/attic-client.nix {};
            attic-server = pkgs.callPackage ./attic/attic-server.nix {};
            element-web = pkgs.callPackage ./matrix/element-web {};
            mautrix-cleanup = inputs.mautrix-cleanup.packages.${pkgs.system}.default;
          }
          // (
            if system == "riscv64-linux"
            then rec {
              vf2Kernel = pkgs.callPackage ./linux/vf2 {kernelPatches = [];};
              vf2KernelPackages = pkgs.linuxPackagesFor vf2Kernel;
            }
            else {}
          );

        overlays = import ./overlays;
        modules = import ./modules;
        lib = import ./lib {inherit pkgs;};

        hydraJobs =
          if (system == "x86_64-linux") || (system == "aarch64-linux")
          then {
            inherit packages devShells formatter;
          }
          else {};
      }
    );
}
