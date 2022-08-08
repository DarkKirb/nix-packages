{
  inputs,
  pkgs,
}:
with pkgs; let
  tarballs = import ../python/tarballs.nix {inherit inputs pkgs;};
in {
  mautrix = with pkgs.python3Packages;
    buildPythonPackage {
      inherit (tarballs.mautrix-src.passthru) pname version;
      src = tarballs.mautrix-src;
      propagatedBuildInputs = [
        aiohttp
        sqlalchemy
        aiosqlite
        ruamel-yaml
        CommonMark
        lxml
      ];
      doCheck = false;
      pythonImportsCheck = ["mautrix"];
    };
  tulir-telethon = with pkgs.python3Packages;
    buildPythonPackage {
      inherit (tarballs.tulir-telethon-src.passthru) pname version;
      src = tarballs.tulir-telethon-src;
      patchPhase = ''
        substituteInPlace telethon/crypto/libssl.py --replace \
          "ctypes.util.find_library('ssl')" "'${lib.getLib openssl}/lib/libssl.so'"
      '';
      propagatedBuildInputs = [
        rsa
        pyaes
      ];
      doCheck = false;
    };
}
