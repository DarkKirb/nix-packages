# Based on https://github.com/Snektron/nixos-vf2/blob/master/pkgs/linux-vf2.nix
{
  lib,
  fetchFromGitHub,
  buildLinux,
  fetchpatch,
  ...
} @ args: let
  modDirVersion = "6.4.0-rc6";
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  buildLinux (args
    // {
      inherit modDirVersion;
      version = "${modDirVersion}-vf2";

      src = fetchFromGitHub {
        owner = "starfive-tech";
        repo = "linux";
        inherit (source) rev sha256;
      };

      defconfig = "starfive_visionfive2_defconfig";

      autoModules = false;
      kernelPreferBuiltin = true;

      structuredExtraConfig = with lib.kernel; {
        ARCH_STARFIVE = yes;
        SOC_STARFIVE = yes;

        SERIAL_8250 = yes;

        NO_HZ_IDLE = yes;
        CPU_FREQ = yes;
        CPUFREQ_DT = yes;
        CPUFREQ_DT_PLATDEV = yes;
        HIBERNATION = yes;

        GPIO_SYSFS = yes;
        POWER_RESET_GPIO_RESET = yes;

        PROC_KCORE = yes;

        PWM = yes;
        PWM_STARFIVE_PTC = yes;

        SIFIVE_CCACHE = yes;

        V4L_PLATFORM_DRIVERS = yes; # TODO: Make module

        PL330_DMA = no;
      };

      extraMeta = {
        branch = "JH7110_VisionFive2_upstream";
        description = "Linux kernel for StarFive's VisionFive2";
        platforms = ["riscv64-linux"];
      };
    }
    // (args.argsOverride or {}))
