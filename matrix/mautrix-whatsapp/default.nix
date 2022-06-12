{ pkgs, inputs, ... } @ args:
let
  buildGoApplication = pkgs.callPackage "${inputs.gomod2nix}/builder" { };
in
{
  mautrix-whatsapp = buildGoApplication rec {
    pname = "mautrix-whatsapp";
    version = inputs.mautrix-whatsapp.lastModifiedDate;
    src = pkgs.callPackage ./source.nix { };
    proxyVendor = true;
    modules = ./gomod2nix.toml;
    CGO_ENABLED = "1";
    buildInputs = [ pkgs.olm ];
  };
}
