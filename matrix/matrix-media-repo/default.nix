{inputs, ...} @ args: let
  pkgs = import inputs.nixpkgs-go116 {inherit (args.pkgs) system;};
  buildGoApplication = pkgs.callPackage "${inputs.gomod2nix}/builder" {};
in {
  matrix-media-repo = buildGoApplication rec {
    pname = "matrix-media-repo";
    version = inputs.matrix-media-repo.lastModifiedDate;
    src = inputs.matrix-media-repo;
    patches = [
      ./async-media.patch
    ];
    go = pkgs.go_1_16;
    proxyVendor = true;
    modules = ./gomod2nix.toml;
    nativeBuildInputs = [
      pkgs.git
    ];
    buildPhase = ''
      GOBIN=$PWD/bin go install -v ./cmd/compile_assets
      $PWD/bin/compile_assets
      GOBIN=$PWD/bin go install -ldflags "-X github.com/turt2live/matrix-media-repo/common/version.GitCommit=$(git rev-list -1 HEAD) -X github.com/turt2live/matrix-media-repo/common/version.Version=$(git describe --tags)" -v ./cmd/...
    '';
    installPhase = ''
      mkdir $out
      cp -rv bin $out
    '';
  };
}
