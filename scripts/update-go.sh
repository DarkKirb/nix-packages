#!/usr/bin/env nix-shell
#!nix-shell -i bash -p go
SOURCE=$1
WRITE_PATH=$(realpath $2)

nix run github:nix-community/gomod2nix -- --dir $SOURCE --outdir $WRITE_PATH
