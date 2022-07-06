#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq 
set -e
PACKAGES="plover-plugins-manager plover-stroke rtf-tokenize plover-regenpfeifer plover-emoji plover-tapey-tape plover-yaml-dictionary"

cat > tarballs.nix << EOF
{ inputs, pkgs }: let
  inherit (pkgs) fetchurl;
in rec {
EOF

for package in $PACKAGES; do
  JSON=$(curl "https://pypi.org/pypi/$package/json")
  FILE_INFO=$(echo -E "$JSON" | jq '.releases[.info.version][] | select (.packagetype == "sdist")')
  VERSION=$(echo -E "$JSON" | jq -r '.info.version')
  URL=$(echo "$FILE_INFO" | jq -r '.url')
  SHA256=$(echo "$FILE_INFO" | jq -r '.digests.sha256')
  cat >> tarballs.nix << EOF
  $package-src = fetchurl {
    url = "$URL";
    sha256 = "$SHA256";
    passthru.pname = "$package";
    passthru.version = "$VERSION";
  };
EOF
done

cat >> tarballs.nix << EOF
}
EOF
