{
  inputs,
  pkgs,
}:
with pkgs; let
  python-packages = import ../python/packages.nix {inherit inputs pkgs;};
in {
  mautrix-signal = with python3Packages;
    buildPythonPackage {
      pname = "mautrix-signal";
      version = inputs.mautrix-signal.lastModifiedDate;
      src = inputs.mautrix-signal;
      propagatedBuildInputs = [
        CommonMark
        aiohttp
        inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.python310Packages.asyncpg
        attrs
        python-packages.mautrix
        phonenumbers
        pillow
        prometheus-client
        pycryptodome
        python-olm
        python-magic
        qrcode
        ruamel-yaml
        unpaddedbase64
        yarl
      ];
      doCheck = false;
    };
}
