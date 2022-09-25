{ stdenv, fetchgit, lib }: let
  src = builtins.fromJSON (builtins.readFile ./source.json);
in stdenv.mkDerivation {
  pname = "lotte-art";
  version = src.date;
  src = fetchgit {
    inherit (src) url rev sha256 fetchLFS fetchSubmodules deepClone leaveDotGit;
  };
  preferLocalBuild = true;
  passthru.updateScript = [
    ../../scripts/update-git.sh
    "https://git.chir.rs/darkkirb/lotte-art"
    "art/lotte/source.json"
    "--fetch-lfs"
  ];
  meta = {
    description = "Art I commissioned (mostly)";
    license = lib.licenses.cc-by-nc-sa-40;
  };
  buildPhase = "true";
  installPhase = "cp -r $src $out";
}
