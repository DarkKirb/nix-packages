{
  pkgs,
  inputs,
}: rec {
  hydra = inputs.hydra.packages.${pkgs.system}.hydra.overrideAttrs (old: {
    doCheck = false;
  });
}
