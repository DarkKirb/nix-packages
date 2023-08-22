#!/usr/bin/env nix-shell
#!nix-shell -i bash -p go
SOURCE=$1
WRITE_PATH=$(realpath $2)

nix run github:darkkirb/gomod2nix -vL -- --dir $SOURCE --outdir $WRITE_PATH
