{
  inputs,
  pkgs,
  ...
}: let
  open-relay = inputs.kreative-open-relay;

  fonts =
    [
      {
        name = "alco-sans";
        path = "AlcoSans/AlcoSans";
      }
      {
        name = "constructium";
        path = "Constructium/Constructium";
      }
      {
        name = "fairfax-hd";
        path = "FairfaxHD/FairfaxHD";
      }
      {
        name = "fairfax-hd-bold";
        path = "FairfaxHD/FairfaxHDBold";
      }
      {
        name = "fairfax-hax-hd";
        path = "FairfaxHD/FairfaxHaxHD";
      }
      {
        name = "fairfax-sm-hd";
        path = "FairfaxHD/FairfaxSMHD";
      }
    ]
    ++ (map (x: {
      name = "fairfax-${pkgs.lib.strings.toLower x}";
      path = "Fairfax/Fairfax${x}";
    }) ["" "Bold" "Italic" "SM" "SMBold" "SMItalic" "Serif" "SerifSM"]);
in
  builtins.listToAttrs (map (v: {
      inherit (v) name;
      value = pkgs.stdenvNoCC.mkDerivation {
        pname = v.name;
        version = open-relay.lastModifiedDate;
        src = open-relay;
        buildPhase = "true";
        installPhase = ''
          install -m444 -Dt $out/share/truetype/${v.name} ${v.path}.ttf
        '';
      };
    })
    fonts)
