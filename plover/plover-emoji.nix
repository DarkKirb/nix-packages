{callPackage, buildPythonPackage, fetchPypi, lib, pythonOlder}:
let plover = callPackage ./plover {};
simplefuzzyset = callPackage ../python/simplefuzzyset.nix {};
in buildPythonPackage rec {
  pname = "plover_emoji";
  version = "0.0.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-3gOyP0ruZrZfaffU7MQjNoG0NUFQLYa/FP3inqpy0VM=";
  };
  
  doCheck = false;

  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [plover simplefuzzyset];
  
  meta = with lib; {
    description = "Convert text to emoji with a stroke.";
    license = licenses.gpl3;
  };
  passthru.updateScript = [../scripts/update-python-libraries "plover/plover-emoji.nix"];
}