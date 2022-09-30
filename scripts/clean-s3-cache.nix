{
  python3,
  boto3,
  stdenvNoCC,
  lib,
}: let
  clean-s3-cache-env = pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [boto3];
  };
in {
  clean-s3-cache = pkgs.stdenvNoCC.mkDerivation {
    name = "clean-s3-cache";
    src = ./clean-s3-cache.py;
    python = clean-s3-cache-env;
    unpackPhase = ''
      cp $src clean-s3-cache.py
    '';
    buildPhase = ''
      substituteAllInPlace clean-s3-cache.py
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp clean-s3-cache.py $out/bin
      chmod +x $out/bin/clean-s3-cache.py
    '';
    meta = {
      description = "Scriept for cleaning a nix s3 binary cache";
      license = lib.licenses.bsd2;
    };
  };
}
