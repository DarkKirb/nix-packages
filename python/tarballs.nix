{
  inputs,
  pkgs,
}: let
  inherit (pkgs) fetchurl;
in rec {
  plover-plugins-manager-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/6c/a1/2db1489c868fd9f88ce164c48bdbf9fcf6e13b7fd323ddba24cd0a7e2e94/plover_plugins_manager-0.7.1.tar.gz";
    sha256 = "fd18966c6c4fb66fb49a10e2d2178455bea204abb2066e883aadb2ae3d7b9fdb";
    passthru.pname = "plover-plugins-manager";
    passthru.version = "0.7.1";
  };
  plover-stroke-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/cc/53/92635d8bf00b883bfbc6ab9dd48b6df2ed01c241379fe99f063a41530cab/plover_stroke-1.1.0.tar.gz";
    sha256 = "de03b23f4aee66b65f69f7d4ecc4233681b43541502d86bf14fde29eaa72d153";
    passthru.pname = "plover-stroke";
    passthru.version = "1.1.0";
  };
  rtf-tokenize-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/1b/c3/591998d6a7e19c68933e8c4af3e8f5c0bbc17eb9c50a229c7c6afff349c4/rtf_tokenize-1.0.0.tar.gz";
    sha256 = "5c3df390d00479bd7637c823bfcd6fdfb21ddd1b96ae815463de7e1ed392d608";
    passthru.pname = "rtf-tokenize";
    passthru.version = "1.0.0";
  };
  plover-emoji-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/44/b0/1e8e677ee942a5817245731493c3541705aad5424a4a21ae4e3bea6a57b6/plover_emoji-0.0.4.tar.gz";
    sha256 = "db6611cd2a094859844b63f6ba2037df7929c4719457556586e9f6ab4f0b57ea";
    passthru.pname = "plover-emoji";
    passthru.version = "0.0.4";
  };
  plover-tapey-tape-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/cf/62/2bddc190fa18009a5e15d1f4efa642aed4a0e0a523c56223616d82ff05c0/plover_tapey_tape-0.0.5.tar.gz";
    sha256 = "226334e874fd9033aba58baf5d9d53523de691b2bba6aad597f71be82923a17c";
    passthru.pname = "plover-tapey-tape";
    passthru.version = "0.0.5";
  };
  plover-yaml-dictionary-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/07/2d/8b23162c1eee648afde6030f64b67a1e9a923ae88ed68dbe9a9c3aef7d14/plover_yaml_dictionary-0.0.1.tar.gz";
    sha256 = "12d9aad7ef5e93559ae5b0236a83b0bfb17697acd722f791cff58206e33023d6";
    passthru.pname = "plover-yaml-dictionary";
    passthru.version = "0.0.1";
  };
  simplefuzzyset-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/ce/bc/7e5d5eaa5566ade033cda9ff0eb51b0942ab2138288b445c469d2814cd2f/simplefuzzyset-0.0.12.tar.gz";
    sha256 = "9a1b30c38b6afb76c6600bdd66c1c1dc3d8505b082e9e3d466f60f40e8b7e1f2";
    passthru.pname = "simplefuzzyset";
    passthru.version = "0.0.12";
  };
  mautrix-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/f0/0b/a758146ad08ea92eade2b2c5a75886c23329a78276d401590358120b8f17/mautrix-0.17.4.tar.gz";
    sha256 = "2505f1bda4fd8e374b98cff761b8cacee10a70fb23b2ed09106973c843a51b33";
    passthru.pname = "mautrix";
    passthru.version = "0.17.4";
  };
  tulir-telethon-src = fetchurl {
    url = "https://files.pythonhosted.org/packages/38/f0/8236f11154532dc0d4e2c161c5c1cff63517fe7d9c05131e92240c11f37c/tulir-telethon-1.25.0a20.tar.gz";
    sha256 = "5fda28f9808d32a42b26f41afcf222f5d16069e4316eb967c14267c2345be897";
    passthru.pname = "tulir-telethon";
    passthru.version = "1.25.0a20";
  };
}
