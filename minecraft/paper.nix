{ pkgs, ... }:
let
  version-info = builtins.fromJSON (builtins.readFile ./paper.json);
  pname = "paper";
  mcVersion = version-info.version;
  buildNum = toString version-info.build;
in
rec {
  paper-jar = pkgs.fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/${version-info.name}";
    inherit (version-info) sha256;
  };
  papermc = pkgs.stdenvNoCC.mkDerivation {
    pname = "papermc";
    version = "${mcVersion}-${buildNum}";

    dontUnpack = true;
    dontConfigure = true;

    buildPhase = ''
      cat > minecraft-server << EOF
      #!${pkgs.bash}/bin/sh
      exec ${pkgs.openjdk17_headless}/bin/java \$@ -jar $out/share/papermc/papermc.jar nogui
    '';

    installPhase = ''
      install -Dm444 ${paper-jar} $out/share/papermc/papermc.jar
      install -Dm555 -t $out/bin minecraft-server
    '';
  };
}
