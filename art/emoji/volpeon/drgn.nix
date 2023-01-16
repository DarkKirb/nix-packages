{callPackage}:
callPackage ../../../lib/mkPleromaEmoji.nix {} rec {
  name = "drgn";
  manifest = ./${name}.json;
  passthru.updateScript = [
    ../../../scripts/update-json.sh
    "https://volpeon.ink/projects/emojis/${name}/manifest.json"
    "art/emoji/volpeon/${name}.json"
  ];
}
