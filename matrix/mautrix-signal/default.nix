{
  lib,
  python3,
  fetchFromGitHub,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  python3.pkgs.buildPythonPackage rec {
    pname = "mautrix-signal";
    version = source.date;
    src = fetchFromGitHub {
      owner = "mautrix";
      repo = "signal";
      inherit (source) rev sha256;
    };
    propagatedBuildInputs = with python3.pkgs; [
      CommonMark
      aiohttp
      asyncpg
      attrs
      (python3.pkgs.callPackage ../../python/mautrix-1.19.nix {})
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

    postPatch = ''
      substituteInPlace requirements.txt \
        --replace "asyncpg>=0.20,<0.26" "asyncpg>=0.20" \
        --replace "mautrix<0.19,>=0.18.9" "mautrix>=0.18.9"
    '';

    postInstall = ''
      mkdir -p $out/bin
      # Make a little wrapper for running mautrix-signal with its dependencies
      echo "$mautrixSignalScript" > $out/bin/mautrix-signal
      echo "#!/bin/sh
        exec python -m mautrix_signal \"\$@\"
      " > $out/bin/mautrix-signal
      chmod +x $out/bin/mautrix-signal
      wrapProgram $out/bin/mautrix-signal \
        --prefix PATH : "${python3}/bin" \
        --prefix PYTHONPATH : "$PYTHONPATH"
    '';

    meta = with lib; {
      homepage = "https://github.com/mautrix/signal";
      description = "A Matrix-Signal puppeting bridge";
      license = licenses.agpl3Plus;
      platforms = platforms.linux;
    };
    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://github.com/mautrix/signal"
      "matrix/mautrix-signal/source.json"
    ];
  }
