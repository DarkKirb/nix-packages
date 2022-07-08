{
  inputs,
  pkgs,
  ...
}: rec {
  miifox-net-source = pkgs.callPackage ./miifox-source.nix {};
  miifox-net = pkgs.stdenvNoCC.mkDerivation {
    pname = "miifox.net";
    version = inputs.miifox-net.lastModifiedDate;
    srcs = miifox-net-source;
    nativeBuildInputs = with pkgs; [
      python3Packages.chevron
      xorg.lndir
    ];
    buildPhase = ''
      chevron -d index.json index.handlebars > index.html
    '';
    installPhase = ''
      mkdir $out
      lndir -silent ${inputs.miifox-net} $out
      cp index.html $out
      rm $out/index.json
    '';
  };
}
