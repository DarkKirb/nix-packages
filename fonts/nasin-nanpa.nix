{ inputs, pkgs, ...}: rec {
  nasin-nanpa = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "nasin-nanpa";
    version = "2.5.25";
    src = inputs.nasin-nanpa;
    nativeBuildInputs = [pkgs.fontforge];
    buildPhase = ''
      fontforge -lang=ff -c 'Open($1); Generate($2)' "ffversions/2.5/nasin-nanpa-${version}.sfd" "nasin-nanpa.otf"
    '';
    installPhase = ''
      install -m444 -Dt $out/share/fonts/opentype/nasin-nanpa nasin-nanpa.otf
    '';
  };
  nasin-nanpa-woff2 = pkgs.stdenvNoCC.mkDerivation rec {
    name = "nasin-nanpa-${nasin-nanpa.version}.woff2";
    inherit (nasin-nanpa) version;
    src = inputs.nasin-nanpa;
    buildInputs = [nasin-nanpa];
    nativeBuildInputs = [pkgs.woff2];
    buildPhase = ''
      cp ${nasin-nanpa}/share/fonts/opentype/nasin-nanpa/nasin-nanpa.otf .
      woff2_compress nasin-nanpa.otf
    '';
    installPhase = ''
      cp nasin-nanpa.woff2 $out
    '';
  };
}
