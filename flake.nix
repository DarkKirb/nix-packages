{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    attic = {
      url = "github:zhaofengli/attic";
      #inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" "riscv64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
        };
        inherit (pkgs) lib;
        nur = import ./default.nix {inherit pkgs;};
        packages = lib.filterAttrs (n: _: n != "overlays" && n != "modules" && n != "lib") nur;
      in rec {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
            nix-prefetch
          ];
        };

        inherit packages;
        inherit (nur) overlays modules lib;

        hydraJobs =
          if (system == "x86_64-linux") || (system == "aarch64-linux") || (system == "riscv64-linux")
          then {
            inherit packages devShells formatter;
          }
          else {};
      }
    );
}
