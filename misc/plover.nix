{
  inputs,
  pkgs,
}:
with pkgs; let
  inherit (inputs.nixpkgs-stable.legacyPackages.${system}) pypy3;
  tarballs = import ../python/tarballs.nix {inherit inputs pkgs;};
in rec {
  plover-plugins-manager = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-plugins-manager-src.passthru) pname version;
      src = tarballs.plover-plugins-manager-src;
      propagatedBuildInputs = [pip pkginfo plover pygments readme_renderer requests requests-cache requests-futures setuptools wheel];
      installCheckPhase = "true";
      setuptoolsCheckPhase = "true";
    };
  plover-stroke = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-stroke-src.passthru) pname version;
      src = tarballs.plover-stroke-src;
      checkInputs = [pytest];
    };
  rtf-tokenize = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.rtf-tokenize-src.passthru) pname version;
      src = tarballs.rtf-tokenize-src;
      checkInputs = [pytest];
    };
  plover-regenpfeifer = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-regenpfeifer-src.passthru) pname version;
      src = tarballs.plover-regenpfeifer-src;
      propagatedBuildInputs = [plover];
    };
  plover-emoji = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-emoji-src.passthru) pname version;
      src = tarballs.plover-emoji-src;
      propagatedBuildInputs = [plover simplefuzzyset];
      checkInputs = [pytest];
    };
  simplefuzzyset = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.simplefuzzyset-src.passthru) pname version;
      src = tarballs.simplefuzzyset-src;
    };
  plover-tapey-tape = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-tapey-tape-src.passthru) pname version;
      src = tarballs.plover-tapey-tape-src;
      propagatedBuildInputs = [plover];
    };
  plover-yaml-dictionary = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-yaml-dictionary-src.passthru) pname version;
      src = tarballs.plover-yaml-dictionary-src;
      propagatedBuildInputs = [plover ruamel-yaml];
    };
  ruamel-yaml = with python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.ruamel-yaml-src.passthru) pname version;
      src = tarballs.ruamel-yaml-src;
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
