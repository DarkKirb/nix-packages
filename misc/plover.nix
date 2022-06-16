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
      propagatedBuildInputs = [pip pkginfo plover pygments readme_renderer requests requests-cache requests-futures setuptools wheel];
      installCheckPhase = "true";
    };
  plover-stroke = with python3Packages;
    buildPythonPackage rec {
      pname = "plover-stroke";
      version = "1.1.0";
      src = fetchFromGitHub {
        owner = "benoit-pierre";
        repo = "plover_plugin_manager";
        rev = "1.1.0";
        sha256 = "sha256-A75OMzmEn0VmDAvmQCp6/7uptxzwWJTwsih3kWlYioA=";
      };
      checkInputs = [pytest];
    };
  rtf-tokenize = with python3Packages;
    buildPythonPackage rec {
      pname = "rtf-tokenize";
      version = "1.0.0";
      src = fetchFromGitHub {
        owner = "benoit-pierre";
        repo = "rtf_tokenize";
        rev = "1.0.0";
        sha256 = "sha256-zwD2sRYTY1Kmm/Ag2hps9VRdUyQoi4zKtDPR+F52t9A=";
      };
      checkInputs = [pytest];
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
      propagatedBuildInputs = [babel pyqt5 xlib pyserial appdirs wcwidth setuptools plover-stroke rtf-tokenize];

      installCheckPhase = "true";

      dontWrapQtApps = true;

      preFixup = ''
        makeWrapperArgs+=("''${qtWrapperArgs[@]}")
      '';
    };
}
