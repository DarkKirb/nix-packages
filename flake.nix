{
  description = "Lotte’s nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
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
    mautrix-discord.url = "github:mautrix/discord";
    mautrix-discord.flake = false;
    mautrix-telegram.url = "github:mautrix/telegram";
    mautrix-telegram.flake = false;
    mautrix-signal.url = "github:mautrix/signal";
    mautrix-signal.flake = false;
    gomod2nix.url = "github:tweag/gomod2nix";
    kreative-open-relay.url = "github:kreativekorp/open-relay";
    kreative-open-relay.flake = false;
    nasin-nanpa.url = "github:ETBCOR/nasin-nanpa";
    nasin-nanpa.flake = false;
    plover.url = "github:benoit-pierre/plover/wayland-sway";
    plover.flake = false;
    cargo2nix.url = "github:cargo2nix/cargo2nix";
    drone-runner-docker.url = "github:drone-runners/drone-runner-docker";
    drone-runner-docker.flake = false;
    copilot-lua.url = "github:zbirenbaum/copilot.lua";
    copilot-lua.flake = false;
    copilot-cmp.url = "github:zbirenbaum/copilot-cmp";
    copilot-cmp.flake = false;
    hydra.url = "github:mlabs-haskell/hydra/aciceri/ca-derivations";
    hydra-patched.url = "git+https://git.chir.rs/darkkirb/hydra?ref=hack";
    hydra-base.url = "git+https://git.chir.rs/darkkirb/hydra?ref=hack&rev=3fdc9e491dc7d33bc09ef4f33984f87c8f478aa2";
    steno-dictionaries.url = "github:didoesdigital/steno-dictionaries";
    steno-dictionaries.flake = false;
    plover-machine-hid.url = "git+https://git.chir.rs/darkkirb/plover-machine-hid";
    plover-machine-hid.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in rec {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            statix
          ];
        };

        packages = pkgs.lib.lists.foldl (a: b: a // b) {} (map (f: import f {inherit pkgs inputs;}) ([
            ./scripts/clean-s3-cache.nix
            ./web/old-homepage.nix
            ./web/miifox-net.nix
            ./mastodon
            ./matrix/matrix-media-repo
            ./matrix/mautrix-whatsapp
            ./matrix/mautrix-discord
            ./matrix/mautrix-telegram.nix
            ./matrix/mautrix-signal.nix
            ./fonts/kreative.nix
            ./fonts/nasin-nanpa.nix
            ./plover
            ./plover/dicts.nix
            ./art
            ./ci/drone-runner-docker
            ./vim
            ./python/tarballs.nix
            ./python/packages.nix
          ]
          ++ (
            if system == "x86_64-linux"
            then [./hydra]
            else []
          )
          ++ (
            if system != "i686-linux"
            then [./minecraft/paper.nix]
            else []
          )));

        hydraJobs =
          if (system == "x86_64-linux") || (system == "aarch64-linux")
          then {
            inherit packages devShells formatter;
            inherit (inputs.cargo2nix.packages.${system}) cargo2nix;
            gomod2nix = inputs.gomod2nix.packages.${system}.default;
          }
          else {};
      }
    );
}
