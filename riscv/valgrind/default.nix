{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  gdb,
  autoreconfHook,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation rec {
    pname = "valgrind-riscv64";
    version = source.date;

    src = fetchFromGitHub {
      owner = "petrpavlu";
      repo = "valgrind-riscv64";
      inherit (source) rev sha256;
    };

    outputs = ["out" "dev"];

    hardeningDisable = ["stackprotector"];

    # GDB is needed to provide a sane default for `--db-command'.
    # Perl is needed for `callgrind_{annotate,control}'.
    buildInputs = [gdb perl];

    # Perl is also a native build input.
    nativeBuildInputs = [autoreconfHook perl];

    enableParallelBuilding = true;
    separateDebugInfo = stdenv.isLinux;

    # To prevent rebuild on linux when moving darwin's postPatch fixes to preConfigure
    postPatch = "";

    doCheck = true;

    postInstall = ''
      for i in $out/libexec/valgrind/*.supp; do
        substituteInPlace $i \
          --replace 'obj:/lib' 'obj:*/lib' \
          --replace 'obj:/usr/X11R6/lib' 'obj:*/lib' \
          --replace 'obj:/usr/lib' 'obj:*/lib'
      done
    '';

    passthru.updateScript = [
      ../../scripts/update-git.sh
      "https://github.com/petrpavlu/valgrind-riscv64"
      "riscv/valgrind/source.json"
    ];

    meta = {
      homepage = "http://www.valgrind.org/";
      description = "Debugging and profiling tool suite";

      longDescription = ''
        Valgrind is an award-winning instrumentation framework for
        building dynamic analysis tools.  There are Valgrind tools that
        can automatically detect many memory management and threading
        bugs, and profile your programs in detail.  You can also use
        Valgrind to build new tools.
      '';

      license = lib.licenses.gpl2Plus;

      maintainers = [lib.maintainers.nickcao];
      platforms = lib.platforms.unix;
      badPlatforms = [
        "armv5tel-linux"
        "armv6l-linux"
        "armv6m-linux"
        "sparc-linux"
        "sparc64-linux"
        "riscv32-linux"
        "alpha-linux"
      ];
      broken = stdenv.isDarwin || stdenv.hostPlatform.isStatic; # https://hydra.nixos.org/build/128521440/nixlog/2
    };
  }
