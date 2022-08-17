{
  inputs,
  pkgs,
}:
with pkgs; let
  python-packages = import ../python/packages.nix {inherit inputs pkgs;};
in {
  mautrix-telegram = with python3Packages;
    buildPythonPackage {
      pname = "mautrix-telegram";
      version = inputs.mautrix-telegram.lastModifiedDate;
      src = inputs.mautrix-telegram;
      patches = ["${inputs.nixpkgs}/pkgs/servers/mautrix-telegram/0001-Re-add-entrypoint.patch" ./mautrix-telegram-sticker.patch];
      propagatedBuildInputs = [
        Mako
        aiohttp
        python-packages.mautrix
        sqlalchemy
        CommonMark
        ruamel-yaml
        python-magic
        python-packages.tulir-telethon
        telethon-session-sqlalchemy
        pillow
        lxml
        setuptools
        prometheus-client
        asyncpg
        python-olm
        pycryptodome
        unpaddedbase64
        psycopg2
        aiosqlite
      ];
      doCheck = false;
    };
}
