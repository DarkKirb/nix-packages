{
  pkgs,
  inputs,
  ...
} @ args: let
  inherit ((pkgs.callPackage "${inputs.gomod2nix}/builder" {})) buildGoApplication;
in {
  mautrix-whatsapp = buildGoApplication rec {
    pname = "mautrix-whatsapp";
    version = inputs.mautrix-whatsapp.lastModifiedDate;
    src = pkgs.callPackage ./source.nix {};
    proxyVendor = true;
    modules = ./gomod2nix.toml;
    CGO_ENABLED = "1";
    buildInputs = [pkgs.olm];
  };
}
