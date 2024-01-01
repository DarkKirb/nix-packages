{
  nix-packages,
  nixpkgs,
  system,
  crossSystem ? system,
}: let
  pkgs = import nixpkgs {
    inherit system crossSystem;
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      contentAddressedByDefault = true;
    };
  };
  ci = import nix-packages {inherit pkgs;};
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
in
  pkgs.lib.filterAttrs (name: _: !(isReserved name)) ci
