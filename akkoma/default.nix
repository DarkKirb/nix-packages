{
  lib,
  beamPackages,
  fetchFromGitea,
  fetchFromGitHub,
  fetchFromGitLab,
  cmake,
  file,
  writeText,
  writeScript,
  applyPatches,
  ...
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = applyPatches {
    src = fetchFromGitea {
      domain = "akkoma.dev";
      owner = "AkkomaGang";
      repo = "akkoma";
      inherit (source) rev sha256;
    };
    patches = [
      ./akkoma.patch
      ./jxl-polyfill.patch
      ./block-invalid-datetime-mrf.patch
      ./require-image-description.patch
      ./make-uploads-private.patch
      ./0001-Revert-Config-Restrict-permissions-of-OTP-config-fil.patch
      ./0001-make-previews-not-break-on-apps-like-telegram.patch
    ];
  };
  mkOverride = final: prev: name:
    prev.${name}.override {
      patchPhase = ''
        mkdir -p config
        cp ${final.mime}/config/config.exs config/config.exs
      '';
    };
  mkOverrides = final: prev: names:
    builtins.listToAttrs (map (name: {
        inherit name;
        value = mkOverride final prev name;
      })
      names);
in
  beamPackages.mixRelease rec {
    pname = "akkoma";
    version = source.date;

    inherit src;

    # Correct version number and remove dependency on OS_Mon
    postPatch = ''
      sed -E -i \
        -e 's/(version\(")\d+\.\d+\.\d+("\))/\1${version}\2/' \
        -e 's/(^|\s):os_mon,//' \
        mix.exs
    '';

    # cf. https://github.com/whitfin/cachex/issues/205
    stripDebug = false;

    mixNixDeps = import ./mix.nix {
      inherit beamPackages lib;
      overrides = final: prev:
        {
          # mix2nix does not support git dependencies yet,
          # so we need to add them manually
          captcha = beamPackages.buildMix {
            name = "captcha";
            version = "0.1.0";

            src = fetchFromGitLab {
              domain = "git.pleroma.social";
              group = "pleroma";
              owner = "elixir-libraries";
              repo = "elixir-captcha";
              rev = "3bbfa8b5ea13accc1b1c40579a380d8e5cfd6ad2";
              sha256 = "1fknjlshc52hrd841rw5incp47h1fk20h068gq9mbskq051p8imj";
            };
            beamDeps = [];
          };
          concurrent_limiter = beamPackages.buildMix rec {
            name = "concurrent_limiter";
            version = "0.1.1";

            src = fetchFromGitea {
              domain = "akkoma.dev";
              owner = "AkkomaGang";
              repo = "concurrent-limiter";
              rev = "a9e0b3d64574bdba761f429bb4fba0cf687b3338";
              hash = "sha256-A7ucZnXks4K+JDVY5vV2cT5KfEOUOo/OHO4rga5mGys=";
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
              hash = "sha256-CtmQHVl+VTpemne+nxbkYGcErrgCo+t3ZBPbkFSpyF0=";
            };

            beamDeps = with final; [];
          };
          file_ex = beamPackages.buildMix rec {
            name = "file_ex";
            version = "0.1.0";

            src = fetchFromGitea {
              domain = "akkoma.dev";
              owner = "AkkomaGang";
              repo = "file_ex";
              rev = "cc7067c7d446c2526e9ecf91d40896b088851569";
              hash = "sha256-3sxfdOy0cpst4jiutoaabk72VFJ2USKiJN9ODN01Dco=";
            };

            beamDeps = with final; [];
          };
          http_signatures = beamPackages.buildMix rec {
            name = "http_signatures";
            version = "0.1.1";

            src = fetchFromGitea {
              domain = "akkoma.dev";
              owner = "AkkomaGang";
              repo = "http_signatures";
              rev = "6640ce7d24c783ac2ef56e27d00d12e8dc85f396";
              hash = "sha256-Q/IoVbM/TBgGCmx8AxiBHF2hARb0FbPml8N1HjN3CsE=";
            };

            patchPhase = ''
              substituteInPlace mix.exs --replace ":logger" ":logger, :public_key"
            '';

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
              hash = "sha256-e3wzlbRuyw/UB5Tb7IozX/WR1T+sIBf9C/o5Thki9vg=";
            };

            beamDeps = with final; [];
          };
          majic = beamPackages.buildMix rec {
            name = "majic";
            version = "1.0.0";

            src = fetchFromGitea {
              domain = "akkoma.dev";
              owner = "AkkomaGang";
              repo = "majic";
              rev = "80540b36939ec83f48e76c61e5000e0fd67706f0";
              hash = "sha256-OMM9aDRvbqCOBIE+iPySU8ONRn1BqHDql22rRSmdW08=";
            };
            buildInputs = [file];

            beamDeps = with final; [elixir_make mime nimble_pool plug];
            patchPhase = ''
              mkdir -p config
              cp ${final.mime}/config/config.exs config/config.exs
            '';
          };
          mfm_parser = beamPackages.buildMix rec {
            name = "mfm_parser";
            version = "0.1.1";

            src = fetchFromGitea {
              domain = "akkoma.dev";
              owner = "AkkomaGang";
              repo = "mfm-parser";
              rev = "b21ab7754024af096f2d14247574f55f0063295b";
              hash = "sha256-couG5jrAo0Fbk/WABd4n3vhXpDUp+9drxExKc5NM9CI=";
            };

            beamDeps = with final; [phoenix_view temple];
          };
          search_parser = beamPackages.buildMix rec {
            name = "search_parser";
            version = "0.1.0";

            src = fetchFromGitHub {
              owner = "FloatingGhost";
              repo = "pleroma-contrib-search-parser";
              rev = "08971a81e68686f9ac465cfb6661d51c5e4e1e7f";
              hash = "sha256-sbo9Kcp2oT05o2GAF+IgziLPYmCkWgBfFMBCytmqg3Y=";
            };

            beamDeps = with final; [nimble_parsec];
          };
          temple = beamPackages.buildMix rec {
            name = "temple";
            version = "0.9.0-rc.0";

            src = fetchFromGitea {
              domain = "akkoma.dev";
              owner = "AkkomaGang";
              repo = "temple";
              rev = "066a699ade472d8fa42a9d730b29a61af9bc8b59";
              hash = "sha256-qA0z8WTMjO2OixcZBARn/LbuV3s3LGtwZ9nSjj/tWBc=";
            };

            mixEnv = "dev";
            beamDeps = with final; [earmark_parser ex_doc makeup makeup_elixir makeup_erlang nimble_parsec];
          };

          fast_html = prev.fast_html.override {
            nativeBuildInputs = [cmake];
            dontUseCmakeConfigure = true;
          };
          syslog = prev.syslog.override {
            buildPlugins = with beamPackages; [pc];
          };
          mime = prev.mime.override {
            patchPhase = let
              cfgFile = writeText "config.exs" ''
                use Mix.Config
                config :mime, :types, %{
                  "application/xml" => ["xml"],
                  "application/xrd+xml" => ["xrd+xml"],
                  "application/jrd+json" => ["jrd+json"],
                  "application/activity+json" => ["activity+json"],
                  "application/ld+json" => ["activity+json"]
                }
                config :mime, :extensions, %{
                  "activity+json" => "application/activity+json"
                }
              '';
            in ''
              mkdir config
              cp ${cfgFile} config/config.exs
            '';
            postInstall = ''
              mkdir -p $out/config
              cp config/config.exs $out/config/config.exs
            '';
          };
        }
        // (mkOverrides final prev [
          "ex_aws"
          "finch"
          "ex_aws_s3"
          "plug"
          "tesla"
          "cors_plug"
          "fast_sanitize"
          "open_api_spex"
          "phoenix_html"
          "plug_cowboy"
          "phoenix_template"
          "phoenix_view"
          "websock_adapter"
          "phoenix"
          "trailing_format_plug"
          "phoenix_live_view"
          "phoenix_live_dashboard"
          "phoenix_ecto"
          "remote_ip"
          "plug_static_index_html"
          "ueberauth"
          "swoosh"
          "phoenix_swoosh"
          "telemetry_metrics_prometheus"
        ]);
    };

    passthru = {
      inherit mixNixDeps;
      updateScript = writeScript "update-akkoma" ''
        ${../scripts/update-git.sh} https://akkoma.dev/AkkomaGang/akkoma.git akkoma/source.json
        if [ "$(git diff -- akkoma/source.json)" ]; then
          SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
          ${../scripts/update-mix.sh} $SRC_PATH akkoma/mix.nix
        fi
      '';
    };

    meta = with lib; {
      description = "ActivityPub microblogging server";
      homepage = "https://akkoma.dev";
      license = licenses.agpl3;
      platforms = platforms.unix;
    };
  }
