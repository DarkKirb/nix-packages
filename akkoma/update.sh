#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-git jq mix2nix
set -e

WORK_DIR=$(mktemp -d)
URL=https://akkoma.dev/AkkomaGang/akkoma
REVISION=$(jq -r '.nodes."akkoma".locked.rev' ../flake.lock)
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

echo "creating mix.nix"

mix2nix $SOURCE_DIR/mix.lock > mix.nix

