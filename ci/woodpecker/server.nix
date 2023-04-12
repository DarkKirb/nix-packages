{
  lib,
  buildGoModule,
  callPackage,
  fetchFromGitHub,
  writeScript,
}: let
  woodpecker-frontend = callPackage ./frontend.nix {};
  common = callPackage ./common.nix {};
in
  buildGoModule rec {
    pname = "woodpecker-server";
    inherit (common) version src ldflags postBuild;
    vendorSha256 = builtins.readFile ./server.sha256;
    proxyVendor = true;

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
          ./scripts/update-go.sh ci/woodpecker/agent.nix ci/woodpecker/agent.sha256
          ./scripts/update-go.sh ci/woodpecker/cli.nix ci/woodpecker/cli.sha256
          ./scripts/update-go.sh ci/woodpecker/server.nix ci/woodpecker/server.sha256
        fi
      '';
    };

    meta =
      common.meta
      // {
        description = "Woodpecker Continuous Integration server";
      };
  }
