{
  callPackage,
  lib,
  writeScript,
  jq,
}:
((callPackage ./common.nix {}).workspace.attic-server {}).overrideAttrs (super: {
  meta = with lib; {
    attic-client = pkgs.callPackage ./attic/attic-client.nix {};
    description = "nix cache server";
    homepage = "https://docs.attic.rs/";
    license = licenses.asl20;
  };
  passthru.updateScript = writeScript "update-attic" ''
    ${../scripts/update-git.sh} https://github.com/zhaofengli/attic attic/source.json
    if [ "$(git diff -- attic/source.json)" ]; then
      SRC_PATH=$(${jq} -r '.source' attic/source.json)
      ${../scripts/update-cargo.sh} $SRC_PATH attic/
    fi
  '';
})
