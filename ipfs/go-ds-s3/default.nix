{
  buildGoApplication,
  fetchFromGitHub,
  gnumake,
  stdenv,
  openssl,
  pkg-config,
  writeScript,
  go_1_21,
}:
buildGoApplication rec {
  pname = "go-ds-s3";
  version = "0.24.0";
  src = fetchFromGitHub {
    owner = "ipfs";
    repo = pname;
    rev = "${pname}-plugin/v${version}";
    sha256 = "030fp5c88qhb7w41x9cy69bmva8g3km294ld2cjwjyz6ljxhlisa";
  };
  modules = ./gomod2nix.toml;
  buildInputs = [openssl];
  nativeBuildInputs = [gnumake pkg-config];
  subPackages = ["${pname}-plugin"];
  buildPhase = ''
    make plugin
  '';
  installPhase = ''
    mkdir $out
    cp ./go-ds-s3-plugin/go-ds-s3-plugin $out
    chmod +x $out/go-ds-s3-plugin
  '';
  postConfigure = ''
    chmod -R +w vendor/
    for f in $(find vendor/github.com/ipfs/boxo/gateway/assets -type l) vendor/github.com/ipfs/go-graphsync/message/ipldbind/*.ipldsch; do
        cp -v --remove-destination -f `readlink $f` $f
    done
  '';
  go = go_1_21;
}
