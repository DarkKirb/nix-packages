{
  inputs,
  pkgs,
}:
with pkgs; let
  inherit (inputs.nixpkgs-stable.legacyPackages.${system}) pypy3;
in rec {
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
      setuptoolsCheckPhase = "true";
    };
  plover-stroke = with python3Packages;
    buildPythonPackage rec {
      pname = "plover-stroke";
      version = "1.1.0";
      src = fetchFromGitHub {
        owner = "benoit-pierre";
        repo = "plover_stroke";
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
  plover-regenpfeifer = with python3Packages;
    buildPythonPackage rec {
      pname = "plover_regenpfeifer";
      version = "0.0.3";
      src = fetchFromGitHub {
        owner = "mkrnr";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-2KzVz8zsrRPU4zjlzyPYfBCWppfy73+nrT5RUKU/670=";
      };
      propagatedBuildInputs = [plover];
    };
  regenpfeifer-env = pypy3.withPackages (ps: [ps.marisa-trie]);
  wortformliste = pkgs.stdenvNoCC.mkDerivation {
    pname = "wortformliste";
    version = inputs.wortformliste.lastModifiedDate;
    src = inputs.wortformliste;

    buildPhase = "true";
    installPhase = "cp wortformliste.csv $out";
  };
  regenpfeifer = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "regenpfeifer";
    version = inputs.regenpfeifer.lastModifiedDate;
    name = "${pname}-${version}.json";
    src = inputs.regenpfeifer;
    patches = [
      ./regenpfeifer.patch
    ];
    nativeBuildInputs = [regenpfeifer-env];
    buildPhase = ''
      PYTHONPATH=${regenpfeifer-env}/site-packages LC_ALL=C.UTF-8 pypy3 -m regenpfeifer.dictionary_generator ${wortformliste} $out unmatched.log 0 0
    '';
    installPhase = "true";
  };
  plover = with python3Packages;
    qt5.mkDerivationWith buildPythonPackage rec {
      pname = "plover";
      version = inputs.plover.lastModifiedDate;

      src = inputs.plover;

      # I'm not sure why we don't find PyQt5 here but there's a similar
      # sed on many of the platforms Plover builds for
      postPatch = ''
        sed -i /PyQt5/d setup.cfg
        sed -i 's/pywayland==0.4.11/pywayland>=0.4.11/' reqs/constraints.txt
        substituteInPlace plover_build_utils/setup.py \
          --replace "/usr/share/wayland/wayland.xml" "${wayland}/share/wayland/wayland.xml"
      '';

      checkInputs = [pytest mock];
      propagatedBuildInputs = [babel pyqt5 xlib pyserial appdirs wcwidth setuptools plover-stroke rtf-tokenize pywayland xkbcommon];
      nativeBuildInputs = [
        wayland
        pkg-config
      ];

      installCheckPhase = "true";

      dontWrapQtApps = true;

      preFixup = ''
        makeWrapperArgs+=("''${qtWrapperArgs[@]}")
      '';
    };
}
