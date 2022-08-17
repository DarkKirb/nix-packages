{
  applyPatches,
  fetchgit,
}:
applyPatches {
  src = fetchgit {
    url = "https://github.com/turt2live/matrix-media-repo";
    rev = "b821ac0a9e2bb152fc3f572e6d502c3266e99ea5";
    sha256 = "0b6s6b6qcal5la5i8z13b6rqizk99j51v5dils7bkjag8zbvhj84";
    leaveDotGit = true;
  };
  patches = [
    ./async-media.patch
  ];
}
