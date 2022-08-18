#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-git nix-prefetch jq
set -e

WORK_DIR=$(mktemp -d)
URL=https://github.com/turt2live/matrix-media-repo
REVISION=$(jq -r '.nodes."matrix-media-repo".locked.rev' ../../flake.lock)
TARGET_DIR="$PWD"

function cleanup {
    grep "fatal" $WORK_DIR/nix-prefetch-git.out >/dev/stderr || true
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

echo "Fetching source code $REVISION from $URL"
JSON=$(nix-prefetch-git --url "$URL" --rev "$REVISION" --leave-dotGit 2> $WORK_DIR/nix-prefetch-git.out)
SHA=$(echo $JSON | jq -r .sha256)
SOURCE_DIR=$(grep '^path is' $WORK_DIR/nix-prefetch-git.out | sed 's/^path is //')

cat > source.nix << EOF
{applyPatches, fetchgit}:
applyPatches {
  src = fetchgit {
    url = "$URL";
    rev = "$REVISION";
    sha256 = "$SHA";
    leaveDotGit = true;
  };
  patches = [
    ./async-media.patch
  ];
}
EOF
SOURCE_DIR="$(nix-build --no-out-link -E '(import <nixpkgs> {}).callPackage ./source.nix {}')"

