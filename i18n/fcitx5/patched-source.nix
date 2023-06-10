{
  fcitx5,
  stdenv,
  callPackage,
}: let
  unicode-data = callPackage ./gen-unicode-data.nix {};
in
  stdenv.mkDerivation {
    pname = "fcitx5-src";
    inherit (fcitx5) version src;

    buildPhase = "true";
    installPhase = ''
      cp -r $src $out
      chmod -R +w $out
      cp ${unicode-data}/* $out/src/modules/unicode
    '';
  }
