{
  pkgs,
  ...
}:

{
  imports = [
    ./wlan.nix
    ./bluetooth.nix
    ./sound.nix
  ];

  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.cpu.intel.updateMicrocode = true;

  # x86_android_tablets provides support for most of the tablet's hardware:
  # accelerometer, ambient light sensor, battery information,
  # touchscreen, backlight controller, and audio codec
  # It depends on gpio_crystalcove for device detection and touch support
  boot.kernelModules = [
    "gpio_crystalcove"
    "x86_android_tablets"
  ];

  # External SD cards do not work without SDHCI_QUIRK2_NO_1_8_V for some reason
  # Anyways, we must not override the other quirks set by the kernel
  # (SDHCI_QUIRK2_CARD_ON_NEEDS_BUS_ON, SDHCI_QUIRK2_PRESET_VALUE_BROKEN, SDHCI_QUIRK2_STOP_WITH_TC),
  # otherwise the SD card will be extremely unstable and cause huge system-wide freezes while reading/writing
  # (and even in some cases filesystem corruption)
  #
  # https://github.com/torvalds/linux/blob/c03c1a14507dfaf8b856c2608f9ac216021fc222/drivers/mmc/host/sdhci-pci-core.c#L1276
  boot.extraModprobeConfig = ''
    options sdhci debug_quirks2=0x11C
  '';

  # Needed to be able to mount the rootfs on the external SD card
  boot.initrd.availableKernelModules = [
   "mmc_block"
   "sdhci_acpi"
  ];

  zramSwap.enable = true;
  systemd.oomd = {
    enableRootSlice = true;
    enableSystemSlice = true;
  };
}
