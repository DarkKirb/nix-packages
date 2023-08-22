{
  lib,
  callPackage,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
}: let
  common = callPackage ./common.nix {};
in
  mkYarnPackage {
    pname = "woodpecker-frontend";
    inherit (common) version;

    src = "${common.src}/web";

    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;

    configurePhase = ''
      cp -r $node_modules node_modules
    '';

    buildPhase = ''
      runHook preBuild

      yarn build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -R ./dist $out
      echo "${common.version}" > "$out/version"

      runHook postInstall
    '';

    # Do not attempt generating a tarball for woodpecker-frontend again.
    doDist = false;

    meta =
      common.meta
      // {
        description = "Woodpecker Continuous Integration server frontend";
      };
  }
