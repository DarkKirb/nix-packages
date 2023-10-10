{
  buildGoApplication,
  callPackage,
  go_1_21,
}: let
  common = callPackage ./common.nix {};
in
  buildGoApplication {
    pname = "woodpecker-cli";
    inherit (common) version src ldflags postBuild;
    modules = ./gomod2nix.toml;

    subPackages = "cmd/cli";

    CGO_ENABLED = 0;
    go = go_1_21;

    meta =
      common.meta
      // {
        description = "Command line client for the Woodpecker Continuous Integration server";
      };
  }
