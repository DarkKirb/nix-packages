{
  lib,
  fetchFromGitHub,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in rec {
  version = source.date;

  src = fetchFromGitHub {
    owner = "woodpecker-ci";
    repo = "woodpecker";
    inherit (source) rev sha256;
  };

  postBuild = ''
    mkdir -p $GOPATH/bin
    cd $GOPATH/bin
    for f in *; do
      mv -- "$f" "woodpecker-$f"
    done
    cd -
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/woodpecker-ci/woodpecker/version.Version=${version}"
  ];

  meta = with lib; {
    homepage = "https://woodpecker-ci.org/";
    license = licenses.asl20;
  };
}
