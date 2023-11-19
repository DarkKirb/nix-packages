{
  buildGoApplication,
  fetchFromGitHub,
  gnumake,
  stdenv,
  openssl,
  pkg-config,
  writeScript,
  callPackage,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  s3-ds-plugin = callPackage ../go-ds-s3 {};
in
  buildGoApplication rec {
    pname = "kubo";
    inherit (s3-ds-plugin) version go;
    src = fetchFromGitHub {
      owner = "ipfs";
      repo = "kubo";
      inherit (source) rev sha256;
    };
    modules = ./gomod2nix.toml;
    buildInputs = [openssl];
    nativeBuildInputs = [gnumake pkg-config];
    subPackages = ["cmd/ipfs"];
    tags = ["openssl"];
    postPatch = ''
      patchShebangs .
      substituteInPlace 'misc/systemd/ipfs.service' \
      --replace '/usr/bin/ipfs' "$out/bin/ipfs"
      substituteInPlace 'misc/systemd/ipfs-hardened.service' \
      --replace '/usr/bin/ipfs' "$out/bin/ipfs"
    '';

    outputs = ["out" "systemd_unit" "systemd_unit_hardened"];

    buildPhase = ''
      make build
    '';

    installPhase = ''
        GOBIN=$out/bin make install
      install --mode=444 -D 'misc/systemd/ipfs-api.socket' "$systemd_unit/etc/systemd/system/ipfs-api.socket"
      install --mode=444 -D 'misc/systemd/ipfs-gateway.socket' "$systemd_unit/etc/systemd/system/ipfs-gateway.socket"
      install --mode=444 -D 'misc/systemd/ipfs.service' "$systemd_unit/etc/systemd/system/ipfs.service"

      install --mode=444 -D 'misc/systemd/ipfs-api.socket' "$systemd_unit_hardened/etc/systemd/system/ipfs-api.socket"
      install --mode=444 -D 'misc/systemd/ipfs-gateway.socket' "$systemd_unit_hardened/etc/systemd/system/ipfs-gateway.socket"
      install --mode=444 -D 'misc/systemd/ipfs-hardened.service' "$systemd_unit_hardened/etc/systemd/system/ipfs.service"
    '';
    postConfigure = ''
      chmod -R +w vendor/
      for f in $(find vendor/github.com/ipfs/boxo/gateway/assets -type l) vendor/github.com/ipfs/go-graphsync/message/ipldbind/*.ipldsch; do
          cp -v --remove-destination -f `readlink $f` $f
      done
    '';
    passthru.updateScript = writeScript "update-matrix-media-repo" ''
      ${../../scripts/update-git.sh} "https://github.com/ipfs/kubo" ipfs/kubo/source.json "--rev v${s3-ds-plugin.version}"
      if [ "$(git diff -- ipfs/kubo/source.json)" ]; then
        SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
        ${../../scripts/update-go.sh} $SRC_PATH ipfs/kubo
      fi
    '';
    passthru.repoVersion = "15"; # Also update kubo-migrator when changing the repo version
  }
