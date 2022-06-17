{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # Source files for packages
    clean-s3-cache.url = "git+https://gist.github.com/DarkKirb/533e9e8b9b6dd1badf9b103b4285dc4e";
    clean-s3-cache.flake = false;
    miifox-net.url = "git+https://git.chir.rs/CarolineHusky/MiiFox.net";
    miifox-net.flake = false;
    mastodon.url = "github:glitch-soc/mastodon";
    mastodon.flake = false;
    nixpkgs-go116.url = "github:NixOS/nixpkgs/dab5668f6be905a7f0de39a7d67fd8f78a13d600";
    matrix-media-repo.url = "github:turt2live/matrix-media-repo";
    matrix-media-repo.flake = false;
    mautrix-whatsapp.url = "github:mautrix/whatsapp";
    mautrix-whatsapp.flake = false;
    gomod2nix.url = "github:tweag/gomod2nix";
    kreative-open-relay.url = "github:kreativekorp/open-relay";
    kreative-open-relay.flake = false;
    nasin-nanpa.url = "github:ETBCOR/nasin-nanpa";
    nasin-nanpa.flake = false;
    plover.url = "github:openstenoproject/plover";
    plover.flake = false;
    regenpfeifer.url = "github:mkrnr/regenpfeifer";
    regenpfeifer.flake = false;
    wortformliste.url = "github:mkrnr/wortformliste";
    wortformliste.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem ["aarch64-linux" "x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in rec {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
          ];
        };

        packages = pkgs.lib.lists.foldl (a: b: a // b) {} (map (f: import f {inherit pkgs inputs;}) [
          ./scripts/clean-s3-cache.nix
          ./web/old-homepage.nix
          ./web/miifox-net.nix
          ./minecraft/paper.nix
          ./mastodon
          ./matrix/matrix-media-repo
          ./matrix/mautrix-whatsapp
          ./fonts/kreative.nix
          ./fonts/nasin-nanpa.nix
          ./misc/plover.nix
        ]);

        hydraJobs = {
          inherit packages devShells;
        };
      }
    );
}
