{
  lib,
  buildGoModule,
  callPackage,
  fetchFromGitHub,
}: let
  common = callPackage ./common.nix {};
in
  buildGoModule {
    pname = "woodpecker-cli";
    inherit (common) version src ldflags postBuild;
    vendorSha256 = builtins.readFile ./cli.sha256;
    proxyVendor = true;

    subPackages = "cmd/cli";

    CGO_ENABLED = 0;

    meta =
      common.meta
      // {
        description = "Command line client for the Woodpecker Continuous Integration server";
      };
  }
