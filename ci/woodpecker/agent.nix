{
  buildGoApplication,
  callPackage,
  go_1_21,
}: let
  common = callPackage ./common.nix {};
in
  buildGoApplication {
    pname = "woodpecker-agent";
    inherit (common) version src ldflags postBuild;
    modules = ./gomod2nix.toml;

    subPackages = "cmd/agent";

    CGO_ENABLED = 0;

    go = go_1_21;

    meta =
      common.meta
      // {
        description = "Woodpecker Continuous Integration agent";
      };
  }
