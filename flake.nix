{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # Source files for packages
    clean-s3-cache.url = "git+https://gist.github.com/DarkKirb/533e9e8b9b6dd1badf9b103b4285dc4e";
    clean-s3-cache.flake = false;
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    } @ inputs:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
          ];
        };

        packages = pkgs.lib.lists.foldl (a: b: a // b) { } [
          (import ./scripts/clean-s3-cache.nix { inherit pkgs inputs; })
        ];

        hydraJobs = {
          inherit packages devShells;
        };
      }
    );
}
