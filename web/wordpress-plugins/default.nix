{
  stdenv,
  fetchurl,
  lib,
  unzip
}:
with builtins;
with lib; let
  plugins = lists.init (splitString "\n" (readFile ./plugins));
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
          passthru.updateScript =
            if name == "activitypub"
            then ./update.sh
            else [];
        };
    })
    plugins)
