#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq

curl -L https://papermc.io/api/v2/projects/paper/versions/1.18.2/builds | jq '{"version":.version, "build":.builds[-1].build, "name":.builds[-1].downloads.application.name, "sha256":.builds[-1].downloads.application.sha256}' > paper.json
