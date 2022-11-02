{
  fetchFromGitLab,
  python3,
  certifi,
  flask,
  flask_sqlalchemy,
  flask_mail,
  flask_migrate,
  flask_wtf,
  mastodon-py,
  pandas,
  psutil,
  pygal,
  python-twitter,
  pymysql,
  sentry-sdk,
  authlib,
  cairosvg,
  werkzeug,
  wheel,
  callPackage,
  stdenvNoCC,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = fetchFromGitLab {
    owner = "hexchen";
    repo = "moa";
    inherit (source) rev sha256;
  };
  moa-env = python3.withPackages (_: [
    certifi
    flask
    flask_sqlalchemy
    flask_mail
    flask_migrate
    flask_wtf
    mastodon-py
    pandas
    psutil
    pygal
    python-twitter
    pymysql
    sentry-sdk
    authlib
    cairosvg
    werkzeug
    wheel
    (callPackage ../python/instagram.nix {})
  ]);
in
  stdenvNoCC.mkDerivation {
    pname = "moa";
    version = source.date;
    inherit src;
    buildPhase = ''
      echo "#!/bin/sh" > start.sh
      echo "cd $out" >> start.sh
      echo "${moa-env}/bin/python -m moa.models" >> start.sh
      echo "exec ${moa-env}/bin/python -m moa.worker" >> start.sh
      chmod +x start.sh
    '';

    installPhase = ''
      cp -rv $src $out
      chmod +w $out
      cp start.sh $out
    '';
    meta = {
      description = "Mastodon-Twitter crossposter";
      license = lib.licenses.mit;
    };
    passthru.updateScript = [
      ../scripts/update-git.sh
      "https://gitlab.com/hexchen/moa"
      "moa/source.json"
      "--rev refs/heads/fix/pleroma"
    ];
  }
