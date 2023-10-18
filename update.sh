#!/bin/sh

#./scripts/update-git.sh https://github.com/starfive-tech/linux linux/vf2/source.json "--rev refs/heads/JH7110_VisionFive2_upstream"
#./scripts/update-git.sh https://github.com/koverstreet/bcachefs linux/bcachefs/source.json
./web/wordpress-plugins/update.sh
./web/wordpress-themes/update.sh
nix-shell ./scripts/update.nix
