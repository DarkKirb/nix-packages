{
  stdenvNoCC,
  rustBuilder,
  fetchFromGitHub,
}: let
  sourceJson = builtins.fromJSON (builtins.readFile ./source.json);
  source = stdenvNoCC.mkDerivation {
    pname = "attic-source";
    version = sourceJson.date;
    src = fetchFromGitHub {
      owner = "zhaofengli";
      repo = "attic";
      inherit (sourceJson) rev sha256;
    };
    buildPhase = "true";
    installPhase = ''
      cp -rv $src $out
      chmod -R +w $out
      cp ${./Cargo.lock} $out
    '';
  };
in
  rustBuilder.makePackageSet {
    rustChannel = "stable";
    rustVersion = "latest";
    packageOverrides = pkgs: pkgs.rustBuilder.overrides.all ++ [
      (pkgs.rustBuilder.rustLib.makeOverride {
        name = "attic";
        overrideAttrs = drv: {
          propagatedBuildInputs = drv.propagatedBuildInputs or [] ++ [
            pkgs.nix.dev
          ];
        };
      })
    ];
    packageFun = import ./Cargo.nix;
    workspaceSrc = source;
  }
