{
  pkgs,
  lib,
  ...
}:

{
  hardware.firmware = with pkgs; [
    alsa-firmware
    sof-firmware
  ];

  boot.kernelPatches = [
    {
      name = "enable-wm5102";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        # Support for the WM5102 codec is unfortunately disabled by default on the NixOS kernel, unlike on Fedora
        # Enabling sound support will thus require a full kernel recompilation
        MFD_WM5102 = yes;
        SND_SOC_WM5102 = module;
        SND_SOC_INTEL_BYTCR_WM5102_MACH = module;

        # Devicetree support is unneccessary on x86_64 devices and causes issues with the WM5102 codec,
        # as it conflicts with the x86-android-tablets module:
        # arizona_spi_acpi_android_probe sets pdata->reset to the correct value,
        # which is then overwritten with NULL by arizona_of_get_core_pdata.
        # This causes the codec to fail to initialize with "Reset GPIO missing/malformed: -EBUSY" and "Unknown device ID: ffff".
        # Another solution is to patch out arizona_of_get_core_pdata while keeping CONFIG_OF enabled.
        #
        # https://github.com/torvalds/linux/blob/c03c1a14507dfaf8b856c2608f9ac216021fc222/drivers/mfd/arizona-spi.c#L85
        # https://github.com/torvalds/linux/blob/c03c1a14507dfaf8b856c2608f9ac216021fc222/drivers/mfd/arizona-core.c#L794
        # https://github.com/torvalds/linux/blob/c03c1a14507dfaf8b856c2608f9ac216021fc222/drivers/platform/x86/x86-android-tablets/lenovo.c#L509
        OF = lib.mkForce no;
      };
    }
  ];
}
