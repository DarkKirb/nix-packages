{
  input,
  system,
}: let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  flake-compat = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
  input-src = fetchTarball {
    url = "https://github.com/${lock.nodes.${input}.locked.owner}/${lock.nodes.${input}.locked.repo}/archive/${lock.nodes.${input}.locked.rev}.tar.gz";
    sha256 = lock.nodes.${input}.locked.narHash;
  };
in
  (import flake-compat) {
    src = input-src;
    inherit system;
  }
