{
  pkgs,
  inputs,
  ...
} @ args: {
  matrix-media-repo = pkgs.buildGoModule rec {
    pname = "matrix-media-repo";
    version = inputs.matrix-media-repo.lastModifiedDate;
    src = pkgs.callPackage ./source.nix {};
    vendorSha256 = builtins.readFile ./vendor.sha256;
    nativeBuildInputs = [
      pkgs.git
    ];
    proxyVendor = true;
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
