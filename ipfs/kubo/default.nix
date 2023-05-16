{
  buildGoApplication,
  fetchFromGitHub,
  gnumake,
  stdenv,
  openssl,
  pkg-config,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = stdenv.mkDerivation {
    pname = "kubo-source";
    version = source.date;
    src = fetchFromGitHub {
      owner = "ipfs";
      repo = "kubo";
      inherit (source) rev sha256;
    };
    buildPhase = "";
    installPhase = ''
      cp -r $src $out
      chmod -R +w $out
      cd $out
      cp ${./go.mod} go.mod
      cp ${./go.sum} go.sum
      cp ${./preload.go} plugin/loader/preload.go 
      echo -e "\nstorjds storj.io/ipfs-go-ds-storj/plugin 0" >> plugin/loader/preload_list
      patchShebangs .
    '';
  };
in
  buildGoApplication rec {
    pname = "kubo";
    version = source.date;
    inherit src;
    modules = ./gomod2nix.toml;
    buildInputs = [openssl];
    nativeBuildInputs = [gnumake pkg-config];
    subPackages = ["cmd/ipfs"];
    tags = ["openssl"];
    postPatch = ''
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
    passthru.updateScript = writeScript "update-matrix-media-repo" ''
      ${../../scripts/update-git.sh} "https://github.com/ipfs/kubo" ipfs/kubo/source.json
      if [ "$(git diff -- ipfs/kubo/source.json)" ]; then
        SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
        ${../../scripts/add-go-module.sh} $SRC_PATH ipfs/kubo "storj.io/ipfs-go-ds-storj/plugin@latest"
      fi
    '';
    passthru.repoVersion = "13"; # Also update kubo-migrator when changing the repo version
  }