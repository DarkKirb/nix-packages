{
  pkgs,
  inputs,
}:
with pkgs; rec {akkoma = beamPackages.mixRelease rec {
  pname = "akkoma";
  version = inputs.akkoma.lastModifiedDate;

  src = inputs.akkoma;

  mixNixDeps = import ./mix.nix {
    inherit beamPackages lib;
    overrides = final: prev: {
      # mix2nix does not support git dependencies yet,
      # so we need to add them manually
      captcha = beamPackages.buildMix rec {
        name = "captcha";
        version = "0.1.0";

        src = fetchFromGitLab {
          domain = "git.pleroma.social";
          group = "pleroma";
          owner = "elixir-libraries";
          repo = "elixir-captcha";
          rev = "e0f16822d578866e186a0974d65ad58cddc1e2ab";
          sha256 = "0qbf86l59kmpf1nd82v4141ba9ba75xwmnqzpgbm23fa1hh8pi9c";
        };
        beamDeps = with final; [];
      };
      elasticsearch = beamPackages.buildMix rec {
        name = "elasticsearch";
        version = "1.0.1";
        src = fetchFromGitea {
          domain = "akkoma.dev";
          owner = "AkkomaGang";
          repo = "elasticsearch-elixir";
          rev = "6cd946f75f6ab9042521a009d1d32d29a90113ca";
          sha256 = "0pf8m5a91nqkcivyp8q2p2p08rv0whb9zgkpk9g3lmbyb4fr1n8a";
        };
        beamDeps = with final; [];
      };
      linkify = beamPackages.buildMix rec {
        name = "linkify";
        version = "0.5.2";
        src = fetchFromGitea {
          domain = "akkoma.dev";
          owner = "AkkomaGang";
          repo = "linkify";
          rev = "2567e2c1073fa371fd26fd66dfa5bc77b6919c16";
          sha256 = "1y7n48clwfgs1gyif85c7zar3xaz6f5frnwl0za0zjvfnjak6z3v";
        };
        beamDeps = with final; [];
      };
      mfm_parser = beamPackages.buildMix rec {
        name = "mfm_parser";
        version = "0.1.1";
        src = fetchFromGitea {
          domain = "akkoma.dev";
          owner = "AkkomaGang";
          repo = "mfm-parser";
          rev = "912fba81152d4d572e457fd5427f9875b2bc3dbe";
          sha256 = "0frkklrnxmiq0avsi3pkpx7insg8s81h8j1iy96caasa3h8scxcz";
        };
        beamDeps = with final; [temple];
      };
      temple = beamPackages.buildMix rec {
        name = "temple";
        version = "0.9.0-rc.1";
        src = fetchFromGitea {
          domain = "akkoma.dev";
          owner = "AkkomaGang";
          repo = "temple";
          rev = "066a699ade472d8fa42a9d730b29a61af9bc8b59";
          sha256 = "05sqxlzqxlnrcxq6nb1pgdbyxdpwcw20868pif7fv36cckqk63d8";
        };
        beamDeps = with final; [];
        patchPhase = ''
          cp config/dev.exs config/prod.exs
        '';
      };

      gettext = beamPackages.buildMix rec {
        name = "gettext";
        version = "0.19.1";
        src = fetchFromGitHub {
          owner = "tusooa";
          repo = "gettext";
          rev = "72fb2496b6c5280ed911bdc3756890e7f38a4808";
          sha256 = "0zbq6yv81cy1zv51rr0ra9h6xdy23x75hrn2b9lba0fww89scjjp";
        };
        beamDeps = with final; [];
      };
      remote_ip = beamPackages.buildMix rec {
        name = "remote_ip";
        version = "0.1.5";

        src = fetchFromGitLab {
          domain = "git.pleroma.social";
          group = "pleroma";
          owner = "elixir-libraries";
          repo = "remote_ip";
          rev = "b647d0deecaa3acb140854fe4bda5b7e1dc6d1c8";
          sha256 = "0c7vmakcxlcs3j040018i7bfd6z0yq6fjfig02g5fgakx398s0x6";
        };
        beamDeps = with final; [combine plug inet_cidr];
      };
      search_parser = beamPackages.buildMix rec {
        name = "search_parser";
        version = "0.1.0";
        src = fetchFromGitHub {
          owner = "FloatingGhost";
          repo = "pleroma-contrib-search-parser";
          rev = "08971a81e68686f9ac465cfb6661d51c5e4e1e7f";
          sha256 = "0xl3mbcwlhn02igh0nm4c1icy8nf43i1g031lcwkv8bnr8lkvfmi";
        };
        beamDeps = with final; [nimble_parsec];
      };
      crypt = beamPackages.buildRebar3 rec {
        name = "crypt";
        version = "0.4.3";

        src = fetchFromGitHub {
          owner = "msantos";
          repo = "crypt";
          rev = "f75cd55325e33cbea198fb41fe41871392f8fb76";
          sha256 = "sha256-ZYhZTe7cTITkl8DZ4z2IOlxTX5gnbJImu/lVJ2ZjR1o=";
        };

        postInstall = "mv $out/lib/erlang/lib/crypt-${version}/priv/{source,crypt}.so";

        beamDeps = with final; [elixir_make];
      };

      # Some additional build inputs and build fixes
      http_signatures = prev.http_signatures.override {
        patchPhase = ''
          substituteInPlace mix.exs --replace ":logger" ":logger, :public_key"
        '';
      };
      fast_html = prev.fast_html.override {
        nativeBuildInputs = [cmake];
        dontUseCmakeConfigure = true;
      };
      syslog = prev.syslog.override {
        buildPlugins = with beamPackages; [pc];
      };

      majic = prev.majic.override {
        buildInputs = [file];
      };

      mime = prev.mime.override {
        patchPhase = let
          cfgFile = writeText "config.exs" ''
            use Mix.Config
            config :mime, :types, %{
              "application/activity+json" => ["activity+json"],
              "application/jrd+json" => ["jrd+json"],
              "application/ld+json" => ["activity+json"],
              "application/xml" => ["xml"],
              "application/xrd+xml" => ["xrd+xml"]
            }
          '';
        in ''
          mkdir config
          cp ${cfgFile} config/config.exs
        '';
      };
    };
  };
};
akkoma-fe = mkYarnPackage rec {
  pname = "akkoma-fe";
  version = inputs.akkoma-fe.lastModifiedDate;
  src = inputs.akkoma-fe;
  patchPhase = ''
    sed -i 's/let commitHash = .*/let commitHash = "${inputs.akkoma-fe.rev}"/' build/webpack.prod.conf.js
    sed -i 's/.*git rev-parse.*//' build/webpack.prod.conf.js
  '';
  buildPhase = "yarn build --offline";
  installPhase = "cp -rv deps/pleroma-fe/dist $out";
};
akkoma-admin-src = applyPatches {
  name = "akkoma-admin-fe-src-${inputs.akkoma-admin-fe.lastModifiedDate}";
  src = inputs.akkoma-admin-fe;
  patches = [
    ./akkoma.patch
  ];
};
akkoma-admin-fe = mkYarnPackage rec {
  pname = "akkoma-admin-fe";
  version = inputs.akkoma-admin-fe.lastModifiedDate;
  src = akkoma-admin-src;
  buildPhase = "yarn build:prod --offline";
};
}
