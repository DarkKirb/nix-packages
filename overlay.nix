# You can use this file as a nixself overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
system: self: super: let
  lib = import ./lib {pkgs = super;}; # functions
  flake = (lib.importFlake {inherit system;}).defaultNix;

  getFlake = flakeName: let
    lib = import ./lib {pkgs = super;};
    flake = (lib.importFlake {inherit system;}).defaultNix;
  in
    flake.inputs.${flakeName};

  getFlakeOverlay = flakeName: overlay: self: super: (getFlake flakeName).outputs.overlays.${overlay} self super;

  riscv-overlay =
    if system == "riscv64-linux"
    then
      (self: super: {
        vf2Kernel = self.callPackage ./linux/vf2 {kernelPatches = [];};
        meson = super.meson.overrideAttrs (_: {
          doCheck = false;
          doInstallCheck = false;
        });
        libarchive = super.libarchive.overrideAttrs (_: {
          doCheck = false;
          doInstallCheck = false;
        });
        openexr = super.openexr.overrideAttrs (_: {
          doCheck = false;
          doInstallCheck = false;
        });
        libopus = super.libopus.overrideAttrs (_: {
          mesonFlags = [
            "-Dfixed-point=false"
            "-Dcustom-modes=true"
            "-Dintrinsics=disabled"
            "-Drtcd=disabled"
            "-Dasm=disabled"
            "-Dasm=disabled"
            "-Ddocs=disabled"
          ];
          doCheck = false;
          doInstallCheck = false;
        });
        valgrind = self.callPackage ./riscv/valgrind {};
        valgrind-light = self.valgrind;
        openldap = super.openldap.overrideAttrs (_: {
          doCheck = false;
          doInstallCheck = false;
        });
      })
    else (_: _: {});

  overlays = [
    (getFlakeOverlay "gomod2nix" "default")
    (self: super: {
      emoji-lotte = self.callPackage ./art/emoji/lotte {};
      emoji-volpeon-blobfox = self.callPackage ./art/emoji/volpeon/blobfox.nix {};
      emoji-volpeon-blobfox-flip = self.callPackage ./art/emoji/volpeon/blobfox_flip.nix {};
      emoji-volpeon-bunhd = self.callPackage ./art/emoji/volpeon/bunhd.nix {};
      emoji-volpeon-bunhd-flip = self.callPackage ./art/emoji/volpeon/bunhd_flip.nix {};
      emoji-volpeon-drgn = self.callPackage ./art/emoji/volpeon/drgn.nix {};
      emoji-volpeon-fox = self.callPackage ./art/emoji/volpeon/fox.nix {};
      emoji-volpeon-gphn = self.callPackage ./art/emoji/volpeon/gphn.nix {};
      emoji-volpeon-raccoon = self.callPackage ./art/emoji/volpeon/raccoon.nix {};
      emoji-volpeon-vlpn = self.callPackage ./art/emoji/volpeon/vlpn.nix {};
      emoji-volpeon-neofox = self.callPackage ./art/emoji/volpeon/neofox.nix {};
      emoji-volpeon-neocat = self.callPackage ./art/emoji/volpeon/neocat.nix {};
      emoji-caro = self.callPackage ./art/emoji/caro {};
      lotte-art = self.callPackage ./art/lotte {};
      alco-sans = self.callPackage ./fonts/kreative/alco-sans.nix {};
      constructium = self.callPackage ./fonts/kreative/constructium.nix {};
      fairfax = self.callPackage ./fonts/kreative/fairfax.nix {};
      fairfax-hd = self.callPackage ./fonts/kreative/fairfax-hd.nix {};
      kreative-square = self.callPackage ./fonts/kreative/kreative-square.nix {};
      nasin-nanpa = self.callPackage ./fonts/nasin-nanpa {};
      matrix-media-repo = self.callPackage ./matrix/matrix-media-repo {};
      mautrix-discord = self.callPackage ./matrix/mautrix-discord {};
      mautrix-whatsapp = self.callPackage ./matrix/mautrix-whatsapp {};
      mautrix-telegram = self.callPackage ./matrix/mautrix-telegram {};
      python-mautrix = self.python3Packages.callPackage ./python/mautrix.nix {};
      python-tulir-telethon = self.python3Packages.callPackage ./python/tulir-telethon.nix {};
      papermc = self.callPackage ./minecraft/papermc {};
      python-plover-stroke = self.python3Packages.callPackage ./plover/plover-stroke.nix {};
      python-rtf-tokenize = self.python3Packages.callPackage ./python/rtf-tokenize.nix {};
      plover = self.python3Packages.callPackage ./plover/plover {};
      plover-plugins-manager = self.python3Packages.callPackage ./plover/plover-plugins-manager.nix {};
      python-simplefuzzyset = self.python3Packages.callPackage ./python/simplefuzzyset.nix {};
      plover-plugin-emoji = self.python3Packages.callPackage ./plover/plover-emoji.nix {};
      plover-plugin-tapey-tape = self.python3Packages.callPackage ./plover/plover-tapey-tape.nix {};
      plover-plugin-yaml-dictionary = self.python3Packages.callPackage ./plover/plover-yaml-dictionary.nix {};
      plover-plugin-python-dictionary = self.python3Packages.callPackage ./plover/plover-python-dictionary.nix {};
      plover-plugin-stenotype-extended = self.python3Packages.callPackage ./plover/plover-stenotype-extended.nix {};
      plover-plugin-machine-hid = self.python3Packages.callPackage ./plover/plover-machine-hid.nix {};
      plover-plugin-rkb1-hid = self.python3Packages.callPackage ./plover/plover-rkb1-hid.nix {};
      plover-plugin-dotool-output = self.python3Packages.callPackage ./plover/plover-dotool-output.nix {};
      plover-dict-didoesdigital = self.callPackage ./plover/didoesdigital-dictionary.nix {};
      miifox-net = self.python3Packages.callPackage ./web/miifox-net.nix {};
      old-homepage = self.callPackage ./web/old-homepage.nix {};
      python-instagram = self.python3Packages.callPackage ./python/instagram.nix {};
      mautrix-cleanup = flake.inputs.mautrix-cleanup.packages.${system}.default;
      hydra = (getFlake "hydra").outputs.packages.${system}.hydra.overrideAttrs (super: {
        doCheck = false;
        patches =
          (super.patches or [])
          ++ [
            ./ci/hydra/add-gitea-push-hook.patch
            ./ci/hydra/jobset-inputs-for-flakes.patch
            ./ci/hydra/remove-hydra-size-limit.patch
          ];
      });
      hydra-unstable = self.hydra;
      kubo = self.callPackage ./ipfs/kubo {};
      asar-asm = self.callPackage ./compiler/asar {};
      bsnes-plus = self.libsForQt5.callPackage ./emulator/bsnes-plus {};
      sliding-sync = self.callPackage ./matrix/sliding-sync {};
      go-ds-s3 = self.callPackage ./ipfs/go-ds-s3 {};
    })
    riscv-overlay
  ];
in
  super.lib.composeManyExtensions overlays self super
