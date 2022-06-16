{
  inputs,
  pkgs,
}:
with pkgs; rec {
  plover-plugins-manager = with python3Packages;
    buildPythonPackage rec {
      pname = "plover-plugins-manager";
      version = "0.7.0";
      src = fetchFromGitHub {
        owner = "benoit-pierre";
        repo = "plover_plugins_manager";
        rev = "0.7.0";
        sha256 = "sha256-+ASEFxjIeqOwwIwojOltA4nAG/HMz+px+wMXuCOc+Dw=";
      };
      propagatedBuildInputs = [plover setuptools];
    };
  plover = with python3Packages;
    qt5.mkDerivationWith buildPythonPackage rec {
      pname = "plover";
      version = inputs.plover.lastModifiedDate;

      src = inputs.plover;

      # I'm not sure why we don't find PyQt5 here but there's a similar
      # sed on many of the platforms Plover builds for
      postPatch = "sed -i /PyQt5/d setup.cfg";

      checkInputs = [pytest mock];
      propagatedBuildInputs = [babel pyqt5 xlib pyserial appdirs wcwidth setuptools];

      dontWrapQtApps = true;

      preFixup = ''
        makeWrapperArgs+=("''${qtWrapperArgs[@]}")
      '';
    };
}
