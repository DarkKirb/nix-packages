{
  pkgs,
  inputs,
  ...
} @ args: let
  inherit ((pkgs.callPackage "${inputs.gomod2nix}/builder" {})) buildGoApplication;
in {
  mautrix-discord = buildGoApplication rec {
    pname = "mautrix-discord";
    version = inputs.mautrix-discord.lastModifiedDate;
    src = pkgs.callPackage ./source.nix {};
    patches = [./sticker.patch];
    proxyVendor = true;
    modules = ./gomod2nix.toml;
    CGO_ENABLED = "1";
    buildInputs = [pkgs.olm];
  };
}
