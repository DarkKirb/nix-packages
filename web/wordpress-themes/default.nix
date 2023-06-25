{
  stdenv,
  fetchurl,
  lib,
  unzip,
}:
with builtins;
with lib; let
  themes = lists.init (splitString "\n" (readFile ./themes));
in
  listToAttrs (map (name: {
      inherit name;
      value = let
        source = importJSON ./${name}.json;
      in
        stdenv.mkDerivation {
          inherit (source) pname version;
          src = fetchurl {
            inherit (source) url sha256;
          };
          nativeBuildInputs = [unzip];
          unpackPhase = ''
            unzip $src
          '';
          installPhase = "mkdir -p $out; cp -R $pname/* $out/";
          meta = {inherit (source) description;};
        };
    })
    themes)
  // {
    passthru.updateScript = ./update.sh;
  }
