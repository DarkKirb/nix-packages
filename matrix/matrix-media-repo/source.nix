{
  applyPatches,
  fetchgit,
}:
applyPatches {
  src = fetchgit {
    url = "https://github.com/turt2live/matrix-media-repo";
    rev = "3184dbc7720fc103aaf4704be894eac69535e887";
    sha256 = "1c1a9hbmq3zjrxfi84i3lwwjld0sn38f8rxwnvsbf8k6ii3jp6d6";
    leaveDotGit = true;
  };
  patches = [
    ./async-media.patch
    ./support-aarch64.patch
  ];
}
