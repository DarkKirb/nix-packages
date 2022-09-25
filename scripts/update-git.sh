#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git
URL=$1
WRITE_PATH=$2

nix-prefetch-git $URL > $WRITE_PATH