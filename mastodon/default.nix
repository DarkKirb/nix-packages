{
  inputs,
  pkgs,
} @ args: let
  pname = "mastodon-glitch";
  version = inputs.mastodon.lastModifiedDate;
  src = inputs.mastodon;
  nasin-nanpa = import ../fonts/nasin-nanpa.nix args;
  patches = [./toki.patch];
in rec {
  mastodon-yarn = (pkgs.callPackage ./yarn.nix {}).offline_cache;
  mastodon-gems = pkgs.bundlerEnv {
    name = "${pname}-gems-${version}";
    inherit version;
    ruby = pkgs.ruby_3_0;
    gemdir = src;
    gemset = ./gemset.nix;
    postBuild = ''
      for gem in "$out"/lib/ruby/gems/*/gems/*; do
        cp -a "$gem/" "$gem.new"
        rm "$gem"
        # needed on macOS, otherwise the mv yields permission denied
        chmod +w "$gem.new"
        mv "$gem.new" "$gem"
      done
    '';
  };
  mastodon-modules = pkgs.stdenv.mkDerivation {
    pname = "${pname}-modules";
    inherit src version patches;

    nativeBuildInputs = with pkgs; [fixup_yarn_lock nodejs-slim yarn mastodon-gems mastodon-gems.wrappedRuby];

    RAILS_ENV = "production";
    NODE_ENV = "production";

    buildPhase = ''
      export HOME=$PWD
      fixup_yarn_lock ~/yarn.lock
      yarn config --offline set yarn-offline-mirror ${mastodon-yarn}
      yarn install --offline --frozen-lockfile --ignore-engines --ignore-scripts --no-progress

      patchShebangs ~/bin
      patchShebangs ~/node_modules

      # skip running yarn install
      rm -rf ~/bin/yarn

      OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder \
        rails assets:precompile
      yarn cache clean --offline
      rm -rf ~/node_modules/.cache
    '';

    installPhase = ''
      mkdir -p $out/public
      cp -r node_modules $out/node_modules
      cp -r public/assets $out/public
      cp -r public/packs $out/public
    '';
  };

  mastodon = pkgs.stdenv.mkDerivation rec {
    inherit pname version src patches;

    propagatedBuildInputs = with pkgs; [imagemagick ffmpeg file mastodon-gems.wrappedRuby];
    buildInputs = with pkgs; [mastodon-gems nodejs-slim];

    buildPhase = ''
      ln -s ${mastodon-modules}/node_modules node_modules
      ln -s ${mastodon-modules}/public/assets public/assets
      ln -s ${mastodon-modules}/public/packs public/packs

      patchShebangs bin/
      for b in $(ls ${mastodon-gems}/bin/)
      do
        if [ ! -f bin/$b ]; then
          ln -s ${mastodon-gems}/bin/$b bin/$b
        fi
      done

      rm -rf log
      ln -s /var/log/mastodon log
      ln -s /tmp tmp
    '';

    installPhase = let
      run-streaming = pkgs.writeShellScript "run-streaming.sh" ''
        # NixOS helper script to consistently use the same NodeJS version the package was built with.
        ${pkgs.nodejs-slim}/bin/node ./streaming
      '';
    in ''
      mkdir -p $out
      cp -r * $out/
      ln -s ${nasin-nanpa.nasin-nanpa-woff2} $out/public/nasin-nanpa.woff2
      ln -s ${run-streaming} $out/run-streaming.sh
    '';
  };
}
