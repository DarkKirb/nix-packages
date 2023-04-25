#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

cd web/workpress-plugins

set -ex

for plugin in $(cat plugins); do
    META=$(curl https://api.wordpress.org/plugins/info/1.0/$plugin.json)
    SHA256=$(curl $(echo $META | jq -r '.versions[.version]') | sha256sum | awk '{print $1}')
    echo $META | jq '{"version": .version, "pname": .slug, "description": .name, "url": .versions[.version], "sha256": $SHA256}' --arg SHA256 $SHA256 > $plugin.json
done
