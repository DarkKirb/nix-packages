{
  lib,
  python3,
  fetchFromGitHub,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  python = python3.override {
    packageOverrides = self: super: {
      dask = super.dask.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
      });
      pyarrow = super.pyarrow.overridePythonAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
      });
      tifffile = super.tifffile.overridePythonAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
      });
      websockets = super.websockets.overridePythonAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
      });
    };
  };
in
  python.pkgs.buildPythonPackage rec {
    pname = "mautrix-telegram";
    version = source.date;
    disabled = python.pythonOlder "3.8";

    src = fetchFromGitHub {
      owner = "mautrix";
      repo = "telegram";
      inherit (source) rev sha256;
    };

    patches = [./0001-Re-add-entrypoint.patch ./mautrix-telegram-sticker.patch];

    postPatch = ''
      substituteInPlace requirements.txt \
        --replace "asyncpg>=0.20,<0.27" "asyncpg>=0.20"
    '';

    propagatedBuildInputs = with python.pkgs; [
      ruamel-yaml
      python-magic
      CommonMark
      aiohttp
      yarl
      (python.pkgs.callPackage ../../python/mautrix.nix {})
      (python.pkgs.callPackage ../../python/tulir-telethon.nix {})
      asyncpg
      Mako
      # optional
      cryptg
      cchardet
      aiodns
      brotli
      pillow
      qrcode
      phonenumbers
      prometheus-client
      aiosqlite
      moviepy
      python-olm
      pycryptodome
      unpaddedbase64
      setuptools
    ];

    # has no tests
    doCheck = false;

    meta = with lib; {
      homepage = "https://github.com/mautrix/telegram";
      description = "A Matrix-Telegram hybrid puppeting/relaybot bridge";
      license = licenses.agpl3Plus;
      platforms = platforms.linux;
      broken = !(python.pkgs ? cryptg);
    };
    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://github.com/mautrix/telegram"
      "matrix/mautrix-telegram/source.json"
    ];
  }
