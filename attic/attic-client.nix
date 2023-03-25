{
  callPackage,
  lib,
}:
((callPackage ./common.nix {}).workspace.attic-client {}).overrideAttrs (super: {
  meta = with lib; {
    description = "nix cache server client";
    homepage = "https://docs.attic.rs/";
    license = licenses.asl20;
  };
})
