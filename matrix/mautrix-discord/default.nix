{
  buildGoApplication,
  olm,
  fetchFromGitHub,
  lib,
  writeScript,
  go,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  buildGoApplication rec {
    pname = "mautrix-discord";
    version = source.date;
    src = fetchFromGitHub {
      owner = "mautrix";
      repo = "discord";
      inherit (source) rev sha256;
    };
    modules = ./gomod2nix.toml;
    buildInputs = [
      olm
    ];
    CGO_ENABLED = "1";
    meta = {
      description = "Discord-Matrix double-puppeting bridge";
      license = lib.licenses.agpl3;
      broken = builtins.compareVersions go.version "1.18" < 0;
    };
    passthru.updateScript = writeScript "update-matrix-media-repo" ''
      ${../../scripts/update-git.sh} "https://github.com/mautrix/discord" matrix/mautrix-discord/source.json
      if [ "$(git diff -- matrix/mautrix-discord/source.json)" ]; then
        SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
        ${../../scripts/update-go.sh} $SRC_PATH matrix/mautrix-discord/
      fi
    '';
  }
