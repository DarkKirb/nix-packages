{
  pkgs,
  inputs,
  ...
} @ args: let
  inherit ((pkgs.callPackage "${inputs.gomod2nix}/builder" {})) buildGoApplication;
in {
  drone-runner-docker = buildGoApplication rec {
    pname = "drone-runner-docker";
    version = inputs.drone-runner-docker.lastModifiedDate;
    src = pkgs.callPackage ./source.nix {};
    proxyVendor = true;
    modules = ./gomod2nix.toml;
  };
}
