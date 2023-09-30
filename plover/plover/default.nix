{
  lib,
  callPackage,
  buildPythonPackage,
  qt5,
  pytest,
  mock,
  babel,
  pyqt5,
  xlib,
  pyserial,
  appdirs,
  wcwidth,
  setuptools,
  xkbcommon,
  pkg-config,
  fetchFromGitHub
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  plover-stroke = callPackage ../plover-stroke.nix {};
  rtf-tokenize = callPackage ../../python/rtf-tokenize.nix {};
in
  qt5.mkDerivationWith buildPythonPackage rec {
    pname = "plover";
    version = source.date;
    src = fetchFromGitHub {
      owner = "openstenoproject";
      repo = "plover";
      inherit (source) rev sha256;
    };

    # I'm not sure why we don't find PyQt5 here but there's a similar
    # sed on many of the platforms Plover builds for
    postPatch = ''
      sed -i /PyQt5/d setup.cfg
    '';

    checkInputs = [pytest mock];
    propagatedBuildInputs = [babel pyqt5 xlib pyserial appdirs wcwidth setuptools plover-stroke rtf-tokenize xkbcommon];
    nativeBuildInputs = [
      pkg-config
    ];

    installCheckPhase = "true";

    dontWrapQtApps = true;

    preFixup = ''
      makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    '';

    meta = {
      homepage = "http://www.openstenoproject.org/";
      description = "Open Source Stenography Software";
      license = lib.licenses.gpl2Plus;
    };
    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://github.com/openstenoproject/plover"
      "plover/plover/source.json"
    ];
  }
