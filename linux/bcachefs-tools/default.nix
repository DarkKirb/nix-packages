{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libuuid,
  libsodium,
  keyutils,
  liburcu,
  zlib,
  libaio,
  zstd,
  lz4,
  attr,
  udev,
  valgrind,
  nixosTests,
  fuse3,
  cargo,
  rustc,
  coreutils,
  rustPlatform,
  makeWrapper,
  fuseSupport ? false,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation {
    pname = "bcachefs-tools";
    version = source.date;

    src = fetchFromGitHub {
      owner = "koverstreet";
      repo = "bcachefs-tools";
      inherit (source) rev sha256;
    };

    nativeBuildInputs = [
      pkg-config
      cargo
      rustc
      rustPlatform.cargoSetupHook
      rustPlatform.bindgenHook
      makeWrapper
    ];

    cargoRoot = "rust-src";
    cargoDeps = rustPlatform.importCargoLock {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "bindgen-0.64.0" = "sha256-GNG8as33HLRYJGYe0nw6qBzq86aHiGonyynEM7gaEE4=";
      };
    };

    buildInputs =
      [
        libaio
        keyutils
        lz4

        libsodium
        liburcu
        libuuid
        zstd
        zlib
        attr
        udev
      ]
      ++ lib.optional fuseSupport fuse3;

    doCheck = false; # needs bcachefs module loaded on builder
    checkFlags = ["BCACHEFS_TEST_USE_VALGRIND=no"];
    nativeCheckInputs = [valgrind];

    makeFlags = [
      "PREFIX=${placeholder "out"}"
      "VERSION=${lib.strings.substring 0 7 source.rev}"
      "INITRAMFS_DIR=${placeholder "out"}/etc/initramfs-tools"
    ];

    preCheck = lib.optionalString fuseSupport ''
      rm tests/test_fuse.py
    '';

    passthru.updateScript = writeScript "update-bcachefs" ''
      ${../../scripts/update-git.sh} https://github.com/koverstreet/bcachefs-tools linux/bcachefs-tools/source.json
      if [ "$(git diff -- linux/bcachefs-tools/source.json)" ]; then
        SRC_PATH=$(nix-build -E '(import ./. {}).bcachefs-tools.src')
        cp $SRC_PATH/rust-src/Cargo.lock linux/bcachefs-tools
      fi
    '';

    postFixup = ''
      wrapProgram $out/bin/mount.bcachefs \
        --prefix PATH : ${lib.makeBinPath [coreutils]}
    '';

    enableParallelBuilding = true;

    meta = with lib; {
      description = "Tool for managing bcachefs filesystems";
      homepage = "https://bcachefs.org/";
      license = licenses.gpl2;
      maintainers = with maintainers; [davidak Madouura];
      platforms = platforms.linux;
    };
  }
