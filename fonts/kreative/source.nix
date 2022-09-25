{fetchFromGitLab}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  fetchFromGitLab {
    owner = "kreativekorp";
    repo = "openrelay";
    inherit (source) rev sha256;
  }
