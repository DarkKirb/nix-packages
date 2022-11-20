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
      repo = "fedibird-fe";
      inherit (source) rev sha256;
    };
    patches = [./fedibird-fe.patch];
  };
  nodeOptions = callPackage ../../lib/opensslLegacyProvider.nix {};
in
  mkYarnPackage rec {
    pname = "fedibird-fe";
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
    patchPhase = ''
    '';
    configurePhase = ''
      rm -rf node_modules
      yarn config set yarn-offline-mirror ${(callPackage ./yarn.nix {}).offline_cache}
      yarn --offline
    '';
    buildPhase = ''
      export NODE_OPTIONS="${nodeOptions}"
      yarn run build:production --offline
    '';
    installPhase = ''
      cp -rv dist $out
      cp -rv public/packs $out/packs
      cp -rv public/emoji $out/emoji
    '';
    distPhase = ''
      # (Losslessly) optimise compression of image artifacts
      find $out -type f -name '*.jpg' -execdir ${jpegoptim}/bin/jpegoptim -w$NIX_BUILD_CORES {} \;
      find $out -type f -name '*.png' -execdir ${oxipng}/bin/oxipng -o max -t $NIX_BUILD_CORES {} \;
      find $out -type f -name '*.svg' -execdir ${nodePackages.svgo}/bin/svgo {} \;
    '';
    passthru = {
      updateScript = writeScript "update-fedibird-fe" ''
        ${../../scripts/update-git.sh} https://akkoma.dev/AkkomaGang/fedibird-fe.git akkoma/fedibird-fe/source.json
        if [ "$(git diff -- akkoma/fedibird-fe/source.json)" ]; then
          SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
          ${../../scripts/update-yarn.sh} $SRC_PATH akkoma/fedibird-fe
        fi
      '';
    };

    meta = with lib; {
      description = "Fedibird frontend for Akkoma and Pleroma";
      homepage = "https://akkoma.dev/AkkomaGang/fedibird-fe/";
      license = licenses.agpl3;
    };
  }
