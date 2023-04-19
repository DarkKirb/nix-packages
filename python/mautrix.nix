{
  lib,
  buildPythonPackage,
  fetchPypi,
  aiohttp,
  pythonOlder,
  sqlalchemy,
  ruamel-yaml,
  CommonMark,
  lxml,
  aiosqlite,
}:
buildPythonPackage rec {
  pname = "mautrix";
  version = "0.19.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-fsNyASxDcD4IO9Oewr7qs51xCaOWVmBNEP+mRlxl6hY=";
  };

  propagatedBuildInputs = [
    aiohttp

    # defined in optional-requirements.txt
    sqlalchemy
    aiosqlite
    ruamel-yaml
    CommonMark
    lxml
  ];

  disabled = pythonOlder "3.8";

  # no tests available
  doCheck = false;

  pythonImportsCheck = ["mautrix"];

  meta = with lib; {
    homepage = "https://github.com/tulir/mautrix-python";
    description = "A Python 3 asyncio Matrix framework.";
    license = licenses.mpl20;
  };
  passthru.updateScript = [../scripts/update-python-libraries "python/mautrix.nix"];
}
