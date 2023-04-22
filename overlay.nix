# You can use this file as a nixself overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
system: self: super: let
  lib = import ./lib {pkgs = super;}; # functions
  flake = (lib.importFlake {inherit system;}).defaultNix;

  getFlakeOverlay = flakeName: overlay: self: super: let
    lib = import ./lib {pkgs = super;};
    flake = (lib.importFlake {inherit system;}).defaultNix;
  in
    flake.inputs.${flakeName}.outputs.overlays.${overlay} self super;

  riscv-overlay = self: super: {
    vf2Kernel = self.callPackage ./linux/vf2 {kernelPatches = [];};
    vf2KernelPackages = super.linuxPackagesFor self.vf2Kernel;
  };

  overlays = [
    (getFlakeOverlay "attic" "default")
    (getFlakeOverlay "hydra" "default")
    (getFlakeOverlay "gomod2nix" "default")
    (self: super: {
      akkoma = self.callPackage ./akkoma {};
      pleroma-fe = self.callPackage ./akkoma/pleroma-fe {};
      admin-fe = self.callPackage ./akkoma/admin-fe {};
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
      mautrix-signal = self.callPackage ./matrix/mautrix-signal {};
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
      plover-plugin-machine-hid = self.python3Packages.callPackage ./plover/plover-machine-hid.nix {};
      plover-plugin-rkb1-hid = self.python3Packages.callPackage ./plover/plover-rkb1-hid.nix {};
      plover-dict-didoesdigital = self.callPackage ./plover/didoesdigital-dictionary.nix {};
      miifox-net = self.python3Packages.callPackage ./web/miifox-net.nix {};
      old-homepage = self.callPackage ./web/old-homepage.nix {};
      python-instagram = self.python3Packages.callPackage ./python/instagram.nix {};
      element-web = self.callPackage ./matrix/element-web {};
      mautrix-cleanup = flake.inputs.mautrix-cleanup.packages.${system}.default;
      woodpecker-agent = self.callPackage ./ci/woodpecker/agent.nix {};
      woodpecker-cli = self.callPackage ./ci/woodpecker/cli.nix {};
      woodpecker-frontend = self.callPackage ./ci/woodpecker/frontend.nix {};
      woodpecker-server = self.callPackage ./ci/woodpecker/server.nix {};
      hydra = super.hydra.overrideAttrs (super: {
        doCheck = false;
        patches =
          (super.patches or [])
          ++ [
            ./ci/hydra/add-ca-support.patch
            ./ci/hydra/add-gitea-push-hook.patch
            ./ci/hydra/jobset-inputs-for-flakes.patch
            ./ci/hydra/remove-hydra-size-limit.patch
          ];
      });
      hydra-unstable = self.hydra;
    })
    riscv-overlay
  ];
in
  super.lib.composeManyExtensions overlays self super
