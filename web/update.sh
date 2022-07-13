#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-git jq git git-lfs

WORK_DIR=$(mktemp -d)
URL=https://git.chir.rs/CarolineHusky/MiiFox.net
REVISION=$(jq -r '.nodes."miifox-net".locked.rev' ../flake.lock)
TARGET_DIR="$PWD"

function cleanup {
    grep "fatal" $WORK_DIR/nix-prefetch-git.out >/dev/stderr || true
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

echo "Fetching source code $REVISION from $URL"
JSON=$(nix-prefetch-git --url "$URL" --rev "$REVISION" --fetch-lfs 2> $WORK_DIR/nix-prefetch-git.out | grep -v " Git" | grep -v "Git ")
REVISION=$(echo "$JSON" | jq -r .rev)
SHA=$(echo "$JSON" | jq -r .sha256)

cat > miifox-source.nix << EOF
{fetchgit}:
fetchgit {
  url = "$URL";
  rev = "$REVISION";
  sha256 = "$SHA";
  fetchLFS = true;
}
EOF