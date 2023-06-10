{
  python3,
  unicode-character-database,
  unihan-database,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "fcitx5-unicode-data";
  inherit (unicode-character-database) version;

  src = ./.;

  nativeBuildInputs = [python3];

  buildPhase = ''
    cp ${unicode-character-database}/share/unicode/UnicodeData.txt .
    cp ${unicode-character-database}/share/unicode/NamesList.txt .
    cp ${unicode-character-database}/share/unicode/Blocks.txt .
    cp ${unihan-database}/share/unicode/Unihan_Readings.txt .

    python3 gen.py
  '';

  installPhase = ''
    mkdir $out
    cp kcharselect-data $out
    cp kcharselect-translation.cpp $out
  '';
}
