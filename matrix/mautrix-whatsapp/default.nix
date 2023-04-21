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
    pname = "mautrix-whatsapp";
    version = source.date;
    src = fetchFromGitHub {
      owner = "mautrix";
      repo = "whatsapp";
      inherit (source) rev sha256;
    };
    modules = ./gomod2nix.toml;
    buildInputs = [
      olm
    ];
    CGO_ENABLED = "1";
    meta = {
      description = "Whatsapp-Matrix double-puppeting bridge";
      license = lib.licenses.agpl3;
      broken = builtins.compareVersions go.version "1.18" < 0;
    };
    passthru.updateScript = writeScript "update-mautrix-whatsapp" ''
      ${../../scripts/update-git.sh} "https://github.com/mautrix/whatsapp" matrix/mautrix-whatsapp/source.json
      if [ "$(git diff -- matrix/mautrix-whatsapp/source.json)" ]; then
        SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
        ${../../scripts/update-go.sh} $SRC_PATH matrix/mautrix-whatsapp/
      fi
    '';
  }
