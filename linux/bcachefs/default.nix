{
  lib,
  fetchFromGitHub,
  buildLinux,
  ...
} @ args: let
  modDirVersion = "6.6.0";
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  buildLinux (args
    // {
      inherit modDirVersion;
      version = "6.6.0+${source.rev}";
      src = fetchFromGitHub {
        owner = "koverstreet";
        repo = "bcachefs";
        inherit (source) rev sha256;
      };
      structuredExtraConfig = with lib.kernel; {
        BCACHEFS_FS = module;
        BCACHEFS_DEBUG = yes;
        KALLSYMS = yes;
        KALLSYMS_ALL = yes;
        DEBUG_FS = yes;
        DYNAMIC_FTRACE = yes;
        FTRACE = yes;
      };
    })
