{
  stdenvNoCC,
  rustBuilder,
  fetchFromGitHub,
  fetchzip,
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

  rustCxxHeader = stdenvNoCC.mkDerivation {
    pname = "cxx-headers";
    version = "1.0.93";
    src = fetchzip {
              extension = "tar.gz";
              url = "https://crates.io/api/v1/crates/cxx/1.0.93/download";
              sha256 = "sha256-YRmV+d9EwX5D68paAMgl+nUVPdLtoh2uiAlQB5idUy4=";
            };
    buildPhase = "";
    installPhase = ''
      mkdir -p $out/include/rust
      cp include/cxx.h $out/include/rust
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
            pkgs.boost.dev
            rustCxxHeader
            pkgs.libclang.lib
          ];
          LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = "-I${pkgs.nix.dev}/include -I${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc.version} -I${pkgs.gcc-unwrapped}/include/c++/${pkgs.gcc.version}/${pkgs.targetPlatform.config} -I${pkgs.glibc.dev}/include -I${pkgs.boost.dev}/include -I${pkgs.nlohmann_json}/include -I${pkgs.gcc-unwrapped}/lib/gcc/${pkgs.targetPlatform.config}/${pkgs.gcc.version}/include -I${pkgs.gcc-unwrapped}/lib/gcc/${pkgs.targetPlatform.config}/${pkgs.gcc.version}/include-fixed";
        };
      })
    ];
    packageFun = import ./Cargo.nix;
    workspaceSrc = source;
  }
