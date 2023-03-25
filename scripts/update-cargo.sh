#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cargo rustc

SOURCE=$1
WRITE_PATH=$(realpath $2)
SOURCE_EXTRACTED=$(mktemp -du)

cp -r $SOURCE $SOURCE_EXTRACTED
chmod -R +w $SOURCE_EXTRACTED

cd $SOURCE_EXTRACTED

cargo update
yes yes | nix run 'github:DarkKirb/cargo2nix/release-0.11.0'

cp Cargo.lock $WRITE_PATH/Cargo.lock
cp Cargo.nix $WRITE_PATH/Cargo.nix

rm -rf $SOURCE_EXTRACTED
