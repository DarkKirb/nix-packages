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
      postInstall = ''
        mkdir -p $out/bin
        # Make a little wrapper for running mautrix-signal with its dependencies
          echo "$mautrixSignalScript" > $out/bin/mautrix-signal
          echo "#!/bin/sh
          exec python -m mautrix_signal \"\$@\"
          " > $out/bin/mautrix-signal
          chmod +x $out/bin/mautrix-signal
          wrapProgram $out/bin/mautrix-signal \
          --set PATH ${python3}/bin \
          --set PYTHONPATH "$PYTHONPATH"
      '';
    };
}
