{
  buildGoApplication,
  callPackage,
  writeScript,
}: let
  woodpecker-frontend = callPackage ./frontend.nix {};
  common = callPackage ./common.nix {};
in
  buildGoApplication rec {
    pname = "woodpecker-server";
    inherit (common) version src ldflags postBuild;
    modules = ./gomod2nix.toml;

    postPatch = ''
      cp -r ${woodpecker-frontend} web/dist
    '';

    subPackages = "cmd/server";

    CGO_ENABLED = 1;

    patches = [./unlimited-matrix.patch];

    passthru = {
      inherit woodpecker-frontend;

      updateScript = writeScript "update-woodpecker" ''
        ${../../scripts/update-git.sh} https://github.com/woodpecker-ci/woodpecker ci/woodpecker/source.json
        if [ "$(git diff -- ci/woodpecker/source.json)" ]; then
          SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
          ${../../scripts/update-yarn.sh} $SRC_PATH/web ci/woodpecker
          ${../../scripts/update-go.sh} $SRC_PATH ci/woodpecker/
        fi
      '';
    };

    meta =
      common.meta
      // {
        description = "Woodpecker Continuous Integration server";
      };
  }
