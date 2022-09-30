{callPackage, fetchFromGitea}: 
let source = builtins.fromJSON (builtins.readFile ./plover-rkb1-hid.json);
in
(callPackage ./plover-machine-hid.nix {}).overrideAttrs (_: {
  version = source.date;
  src = fetchFromGitea {
    domain = "git.chir.rs";
    owner = "darkkirb";
    repo = "plover-machine-hid";
    inherit (source) rev sha256;
  };
  passthru.updateScript = [../scripts/update-git.sh "https://git.chir.rs/darkkirb/plover-machine-hid" "plover/plover-rkb1-hid.json"];
})
