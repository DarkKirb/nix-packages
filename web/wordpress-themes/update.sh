#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

cd web/workpress-themes

set -ex

for plugin in $(cat themes); do
    META=$(curl https://api.wordpress.org/themes/info/1.1/?action\=theme_information\&request\\\[slug\\\]\=$plugin)
    SHA256=$(curl -L $(echo $META | jq -r '.download_link') | sha256sum | awk '{print $1}')
    echo $META | jq '{"version": .version, "pname": .slug, "description": .name, "url": .download_link, "sha256": $SHA256}' --arg SHA256 $SHA256 > $plugin.json
done
