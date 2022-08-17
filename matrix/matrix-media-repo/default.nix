{pkgs, inputs, ...} @ args: let
  inherit ((pkgs.callPackage "${inputs.gomod2nix}/builder" {})) buildGoApplication;
in {
  matrix-media-repo = buildGoApplication rec {
    pname = "matrix-media-repo";
    version = inputs.matrix-media-repo.lastModifiedDate;
    src = pkgs.callPackage ./source.nix {};
    proxyVendor = true;
    modules = ./gomod2nix.toml;
    nativeBuildInputs = [
      pkgs.git
    ];
    CGO_ENABLED = "1";
    buildPhase = ''
      GOBIN=$PWD/bin go install -v ./cmd/compile_assets
      $PWD/bin/compile_assets
      GOBIN=$PWD/bin go install -ldflags "-X github.com/turt2live/matrix-media-repo/common/version.GitCommit=$(git rev-list -1 HEAD) -X github.com/turt2live/matrix-media-repo/common/version.Version=${version}" -v ./cmd/...
    '';
    installPhase = ''
      mkdir $out
      cp -rv bin $out
    '';
  };
}
