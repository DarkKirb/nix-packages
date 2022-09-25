# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  akkoma = pkgs.callPackage ./akkoma {};
  pleroma-fe = pkgs.callPackage ./akkoma/pleroma-fe {};
  admin-fe = pkgs.callPackage ./akkoma/admin-fe {};
  emoji-volpeon-blobfox = pkgs.callPackage ./art/emoji/volpeon/blobfox.nix {};
  emoji-volpeon-blobfox-flip = pkgs.callPackage ./art/emoji/volpeon/blobfox_flip.nix {};
  emoji-volpeon-bunhd = pkgs.callPackage ./art/emoji/volpeon/bunhd.nix {};
  emoji-volpeon-bunhd-flip = pkgs.callPackage ./art/emoji/volpeon/bunhd_flip.nix {};
  emoji-volpeon-drgn = pkgs.callPackage ./art/emoji/volpeon/drgn.nix {};
  emoji-volpeon-fox = pkgs.callPackage ./art/emoji/volpeon/fox.nix {};
  emoji-volpeon-raccoon = pkgs.callPackage ./art/emoji/volpeon/raccoon.nix {};
  emoji-volpeon-vlpn = pkgs.callPackage ./art/emoji/volpeon/vlpn.nix {};
}
