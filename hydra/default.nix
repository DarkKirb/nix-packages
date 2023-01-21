{
  nix-packages,
  nixpkgs,
  system,
}: let
  pkgs = import nixpkgs {inherit system;};
  ci = import "${nix-packages}/ci.nix" {inherit pkgs;};
in
  ci.buildPkgs
