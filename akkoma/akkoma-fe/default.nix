{
  lib,
  mkYarnPackage,
  fetchFromGitea,
  fetchYarnDeps,
  fixup_yarn_lock,
  yarn,
  nodejs,
  jpegoptim,
  oxipng,
  nodePackages,
  writeScript,
  applyPatches,
  callPackage,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = applyPatches {
    src = fetchFromGitea {
      domain = "akkoma.dev";
      owner = "AkkomaGang";
      repo = "akkoma-fe";
      inherit (source) rev sha256;
    };
    patches = [./akkoma-fe.patch ./jxl-polyfill.patch];
  };
  nodeOptions = callPackage ../../lib/opensslLegacyProvider.nix {};
in
  mkYarnPackage rec {
    pname = "akkoma-fe";
    version = source.date;
    inherit src;
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;

    nativeBuildInputs = [
      jpegoptim
      oxipng
      nodePackages.svgo
    ];
    # Build scripts assume to be used within a Git repository checkout
    patchPhase = ''
      sed -E -i \
        -e '/^let commitHash =/,/;$/clet commitHash = "${builtins.substring 0 7 source.rev}";' \
        build/webpack.prod.conf.js
    '';
    configurePhase = ''
      cp -r $node_modules node_modules
      for f in $(find node_modules/jxl.js -type f); do chmod -v +w $f; done
      for f in $(find node_modules/jxl.js -type l);do cp -rv --remove-destination $(readlink $f) $f;done;
    '';
    buildPhase = ''
      export NODE_OPTIONS="${nodeOptions}"
      yarn build --offline
    '';
    installPhase = "cp -rv dist $out";
    distPhase = ''
      # (Losslessly) optimise compression of image artifacts
      find $out -type f -name '*.jpg' -execdir ${jpegoptim}/bin/jpegoptim -w$NIX_BUILD_CORES {} \;
      find $out -type f -name '*.png' -execdir ${oxipng}/bin/oxipng -o max -t $NIX_BUILD_CORES {} \;
      find $out -type f -name '*.svg' -execdir ${nodePackages.svgo}/bin/svgo {} \;
    '';
    passthru = {
      updateScript = writeScript "update-akkoma-fe" ''
        ${../../scripts/update-git.sh} https://akkoma.dev/AkkomaGang/akkoma-fe.git akkoma/akkoma-fe/source.json
        if [ "$(git diff -- akkoma/akkoma-fe/source.json)" ]; then
          SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
          ${../../scripts/update-yarn.sh} $SRC_PATH akkoma/akkoma-fe
        fi
      '';
    };

    meta = with lib; {
      description = "Frontend for Akkoma and akkoma";
      homepage = "https://akkoma.dev/AkkomaGang/akkoma-fe/";
      license = licenses.agpl3;
    };
  }
