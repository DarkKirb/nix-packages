{ pkgs, inputs }: rec {
  hydra-patch = pkgs.stdenvNoCC.mkDerivation {
    name = "hydra.patch";
    srcs = inputs.hydra-patched;
    nativeBuildInputs = [ pkgs.diffutils ];
    buildPhase = ''
      diff -r -u ${inputs.hydra-base} . > $out || true
    '';
    installPhase = "true";
  };
  hydra = inputs.hydra.packages.${pkgs.system}.hydra.overrideAttrs (old: {
    patches = [
      hydra-patch
    ];
    doCheck = false;
  });
}
