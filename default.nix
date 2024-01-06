# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  lib = import ./lib {inherit pkgs;}; # functions
  flake = (lib.importFlake {inherit (pkgs) system;}).defaultNix;
  pkgsWithOverlay = pkgs.appendOverlays [(import ./overlay.nix pkgs.system)];
in
  {
    # The `lib`, `modules`, and `overlay` names are special
    inherit (flake) lib modules overlays;
  }
  // {
    inherit
      (pkgsWithOverlay)
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
      plover-dict-didoesdigital
      miifox-net
      old-homepage
      plover-plugin-python-dictionary
      plover-plugin-stenotype-extended
      plover-plugin-dotool-output
      asar-asm
      bsnes-plus
      sliding-sync
      ;
  }
  // (
    if pkgs.system == "riscv64-linux"
    then {
      inherit (pkgsWithOverlay) vf2Kernel valgrind;
    }
    else {}
  )
