{ pkgs, inputs }: rec {
  clean-s3-cache-env = pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [ boto3 ];
  };
  clean-s3-cache = pkgs.stdenvNoCC.mkDerivation {
    pname = "clean-s3-cache";
    version = inputs.clean-s3-cache.lastModifiedDate;
    srcs = inputs.clean-s3-cache;
    buildPhase = ''
      sed -i 's|#SHEBANG#|${clean-s3-cache-env}|' clean-s3-cache.py
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp clean-s3-cache.py $out/bin
      chmod +x $out/bin/clean-s3-cache.py
    '';
  };
}
