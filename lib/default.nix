{ pkgs, ...}: {
  mkPleromaEmoji = pkgs.callPackage ./mkPleromaEmoji.nix {};
}
