{callPackage}:
callPackage ../../../lib/mkPleromaEmoji.nix {} rec {
  name = "neocat";
  manifest = ./${name}.json;
  passthru.updateScript = [
    ../../../scripts/update-json.sh
    "https://volpeon.ink/projects/emojis/${name}/manifest.json"
    "art/emoji/volpeon/${name}.json"
  ];
}