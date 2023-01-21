{
  nix-packages,
  nixpkgs,
  system,
}: let
  pkgs = import nixpkgs {inherit system;};
  ci = import nix-packages {inherit pkgs;};
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
in
  pkgs.lib.filterAttrs (name: _: !(isReserved name))
