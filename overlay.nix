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
    vf2Kernel = super.callPackage ./linux/vf2 {kernelPatches = [];};
    vf2KernelPackages = super.linuxPackagesFor self.vf2Kernel;
  };

  overlays = [
    #(getFlakeOverlay "attic" "default")
    #(getFlakeOverlay "hydra" "default")
    (getFlakeOverlay "gomod2nix" "default")

    (self: super: {
      akkoma = super.callPackage ./akkoma {};
      pleroma-fe = super.callPackage ./akkoma/pleroma-fe {};
      admin-fe = super.callPackage ./akkoma/admin-fe {};
      emoji-lotte = super.callPackage ./art/emoji/lotte {};
      emoji-volpeon-blobfox = super.callPackage ./art/emoji/volpeon/blobfox.nix {};
      emoji-volpeon-blobfox-flip = super.callPackage ./art/emoji/volpeon/blobfox_flip.nix {};
      emoji-volpeon-bunhd = super.callPackage ./art/emoji/volpeon/bunhd.nix {};
      emoji-volpeon-bunhd-flip = super.callPackage ./art/emoji/volpeon/bunhd_flip.nix {};
      emoji-volpeon-drgn = super.callPackage ./art/emoji/volpeon/drgn.nix {};
      emoji-volpeon-fox = super.callPackage ./art/emoji/volpeon/fox.nix {};
      emoji-volpeon-gphn = super.callPackage ./art/emoji/volpeon/gphn.nix {};
      emoji-volpeon-raccoon = super.callPackage ./art/emoji/volpeon/raccoon.nix {};
      emoji-volpeon-vlpn = super.callPackage ./art/emoji/volpeon/vlpn.nix {};
      emoji-caro = super.callPackage ./art/emoji/caro {};
      lotte-art = super.callPackage ./art/lotte {};
      alco-sans = super.callPackage ./fonts/kreative/alco-sans.nix {};
      constructium = super.callPackage ./fonts/kreative/constructium.nix {};
      fairfax = super.callPackage ./fonts/kreative/fairfax.nix {};
      fairfax-hd = super.callPackage ./fonts/kreative/fairfax-hd.nix {};
      kreative-square = super.callPackage ./fonts/kreative/kreative-square.nix {};
      nasin-nanpa = super.callPackage ./fonts/nasin-nanpa {};
      matrix-media-repo = super.callPackage ./matrix/matrix-media-repo {};
      mautrix-discord = super.callPackage ./matrix/mautrix-discord {};
      mautrix-whatsapp = super.callPackage ./matrix/mautrix-whatsapp {};
      mautrix-signal = super.callPackage ./matrix/mautrix-signal {};
      mautrix-telegram = super.callPackage ./matrix/mautrix-telegram {};
      python-mautrix = super.python3Packages.callPackage ./python/mautrix.nix {};
      python-tulir-telethon = super.python3Packages.callPackage ./python/tulir-telethon.nix {};
      papermc = super.callPackage ./minecraft/papermc {};
      python-plover-stroke = super.python3Packages.callPackage ./plover/plover-stroke.nix {};
      python-rtf-tokenize = super.python3Packages.callPackage ./python/rtf-tokenize.nix {};
      plover = super.python3Packages.callPackage ./plover/plover {};
      plover-plugins-manager = super.python3Packages.callPackage ./plover/plover-plugins-manager.nix {};
      python-simplefuzzyset = super.python3Packages.callPackage ./python/simplefuzzyset.nix {};
      plover-plugin-emoji = super.python3Packages.callPackage ./plover/plover-emoji.nix {};
      plover-plugin-tapey-tape = super.python3Packages.callPackage ./plover/plover-tapey-tape.nix {};
      plover-plugin-yaml-dictionary = super.python3Packages.callPackage ./plover/plover-yaml-dictionary.nix {};
      plover-plugin-machine-hid = super.python3Packages.callPackage ./plover/plover-machine-hid.nix {};
      plover-plugin-rkb1-hid = super.python3Packages.callPackage ./plover/plover-rkb1-hid.nix {};
      plover-dict-didoesdigital = super.callPackage ./plover/didoesdigital-dictionary.nix {};
      miifox-net = super.python3Packages.callPackage ./web/miifox-net.nix {};
      old-homepage = super.callPackage ./web/old-homepage.nix {};
      python-instagram = super.python3Packages.callPackage ./python/instagram.nix {};
      element-web = super.callPackage ./matrix/element-web {};
      mautrix-cleanup = flake.inputs.mautrix-cleanup.packages.${system}.default;
      woodpecker-agent = super.callPackage ./ci/woodpecker/agent.nix {};
      woodpecker-cli = super.callPackage ./ci/woodpecker/cli.nix {};
      woodpecker-frontend = super.callPackage ./ci/woodpecker/frontend.nix {};
      woodpecker-server = super.callPackage ./ci/woodpecker/server.nix {};
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
