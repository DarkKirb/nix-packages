{
  inputs,
  pkgs,
}:
with pkgs; let
  inherit (inputs.nixpkgs-stable.legacyPackages.${system}) pypy3;
  tarballs = import ../python/tarballs.nix {inherit inputs pkgs;};
  patched-python3Packages = python3Packages.override {
    overrides = self: super: {
      requests-cache = super.requests-cache.overrideAttrs (old: {
        postPatch = ''
          substituteInPlace pyproject.toml --replace 'attrs         = "^21.2"' 'attrs         = ">=21.2"'
        '';
      });
    };
  };
in rec {
  plover-plugins-manager = with patched-python3Packages;
    buildPythonPackage rec {
      inherit (tarballs.plover-plugins-manager-src.passthru) pname version;
      src = tarballs.plover-plugins-manager-src;
      propagatedBuildInputs = [pip pkginfo plover pygments readme_renderer requests requests-cache requests-futures setuptools wheel];
      installCheckPhase = "true";
      setuptoolsCheckPhase = "true";
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
  plover-machine-hid = with python3Packages;
    buildPythonPackage rec {
      pname = "plover-machine-hid";
      version = inputs.plover-machine-hid.lastModifiedDate;
      src = inputs.plover-machine-hid;
      propagatedBuildInputs = [plover hid bitstring];
    };
}
