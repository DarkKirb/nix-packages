{
  inputs,
  pkgs,
}: let
  plover = import ./. {inherit inputs pkgs;};
  dict_list = [
    "abbreviations"
    "apps"
    "bad-habits"
    "briefs"
    "code"
    "computer-powerups"
    "computer-use"
    "condensed-strokes-fingerspelled"
    "condensed-strokes"
    "css-alignment"
    "css-declarations"
    "css-media-object"
    "currency"
    "d3"
    "data-viz"
    "di-briefs"
    "di-nouns"
    "di-proper-nouns"
    "di-spectacle-v1"
    "dict-en-AU-phonetic"
    "dict-en-AU-vocab"
    "dict-en-AU-with-extra-stroke"
    "dict"
    "emoji"
    "fingerspelling-FPLT"
    "fingerspelling-RBGS"
    "fingerspelling-powerups"
    "fingerspelling-right-hand"
    "fingerspelling"
    "git"
    "haxe"
    "html"
    "human-resources"
    "javascript"
    "jquery"
    "lorem"
    "markdown"
    "medical-suffixes"
    "misstrokes"
    "modifiers-single-stroke"
    "modifiers"
    "navigation"
    "nouns"
    "numbers-powerups"
    "numbers"
    "observable"
    "plover-powerups"
    "plover-use"
    "proper-nouns"
    "punctuation-di"
    "punctuation-powerups"
    "punctuation-unspaced"
    "punctuation"
    "python"
    "react"
    "retro-quotes"
    "roman-numerals"
    "ruby"
    "shortcuts"
    "sketch-app"
    "sublime"
    "svg"
    "symbols-briefs"
    "symbols-currency-culled"
    "symbols-currency"
    "symbols"
    "tabbing"
    "top-100-words"
    "top-1000-words"
    "top-10000-project-gutenberg-words"
    "top-200-words-spoken-on-tv"
    "top-level-domains"
    "ux-design"
    "vim"
    "voiceover"
  ];
  json-to-yaml-env = pkgs.python3.buildEnv.override {
    extraLibs = with plover; [ruamel-yaml];
  };
  json-to-yaml = pkgs.stdenvNoCC.mkDerivation {
    name = "json-to-yaml";
    srcs = ./.;
    python = json-to-yaml-env;
    buildPhase = ''
      substituteAllInPlace json-to-yaml.py
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp json-to-yaml.py $out/bin
      chmod +x $out/bin/json-to-yaml.py
    '';
  };
in
  builtins.listToAttrs (builtins.map (name: {
      name = "plover-dict-${name}";
      value = pkgs.stdenvNoCC.mkDerivation {
        name = "plover-dict-${name}-${inputs.steno-dictionaries.lastModifiedDate}.yaml";
        pname = "plover-dict-${name}";
        version = inputs.steno-dictionaries.lastModifiedDate;
        srcs = inputs.steno-dictionaries;
        buildPhase = ''
          ${json-to-yaml}/bin/json-to-yaml.py dictionaries/${name}.json $out
        '';
        installPhase = "true";
      };
    })
    dict_list)
