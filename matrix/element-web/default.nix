{
  lib,
  stdenv,
  runCommand,
  fetchFromGitHub,
  fetchYarnDeps,
  writeText,
  jq,
  yarn,
  fixup_yarn_lock,
  nodejs,
  jitsi-meet,
  writeScript,
  conf ? {},
  callPackage,
}: let
  source = lib.importJSON ./source.json;
  noPhoningHome = {
    disable_guests = true; # disable automatic guest account registration at matrix.org
    piwik = false; # disable analytics
  };
  configOverrides = writeText "element-config-overrides.json" (builtins.toJSON (noPhoningHome // conf));
in
  stdenv.mkDerivation rec {
    pname = "element-web";
    version = source.date;

    src = fetchFromGitHub {
      owner = "DarkKirb";
      repo = pname;
      inherit (source) rev sha256;
    };

    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;

    offlineCache = (callPackage ./yarn.nix {}).offline_cache;

    nativeBuildInputs = [yarn jq nodejs fixup_yarn_lock];

    configurePhase = ''
      runHook preConfigure

      export HOME=$(mktemp -d)

      export NODE_OPTIONS=--openssl-legacy-provider
      cp $packageJSON package.json
      cp $yarnLock yarn.lock
      fixup_yarn_lock yarn.lock
      yarn config --offline set yarn-offline-mirror $offlineCache
      yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
      patchShebangs node_modules

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export VERSION=${version}
      yarn build:res
      yarn build:module_system
      yarn build:bundle

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -R webapp $out
      cp ${jitsi-meet}/libs/external_api.min.js $out/jitsi_external_api.min.js
      echo "${version}" > "$out/version"
      jq -s '.[0] * .[1]' "config.sample.json" "${configOverrides}" > "$out/config.json"

      runHook postInstall
    '';

    passthru = {
      updateScript = writeScript "update-element-web" ''
        ${../../scripts/update-git.sh} https://github.com/DarkKirb/element-web matrix/element-web/source.json
        if [ "$(git diff -- matrix/element-web/source.json)" ]; then
          SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
          ${../../scripts/update-yarn.sh} $SRC_PATH matrix/element-web
        fi
      '';
    };

    meta = {
      description = "A glossy Matrix collaboration client for the web";
      homepage = "https://element.io/";
      changelog = "https://github.com/vector-im/element-web/blob/v${version}/CHANGELOG.md";
      maintainers = lib.teams.matrix.members;
      license = lib.licenses.asl20;
      platforms = lib.platforms.all;
    };
  }
