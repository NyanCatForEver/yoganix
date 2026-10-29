# The Broadcom Wi-Fi will work without this patch, as the firmware binary and NVRAM data are already provided by linux-firmware.
# However, the MAC address provided in that NVRAM file is not the actual MAC address of the device,
# and will be overwritten with a random one by the kernel.
# The Wi-Fi driver on Lenovo's Android build reads the correct MAC address from a hardcoded path (/config/wifi/mac.txt),
# so that's what this firmware patch does.
#
# https://github.com/torvalds/linux/blob/c03c1a14507dfaf8b856c2608f9ac216021fc222/drivers/net/wireless/broadcom/brcm80211/brcmfmac/common.c#L291
# osc_4_blade2_L_result/linux/modules/wlan/PRIVATE/bcm43xx/src/dhd_custom_gpio.c#wifi_get_mac_addr_intel in https://download.lenovo.com/consumer/open_source_code/yoga_tab_2_osc_android_to_lollipop_201505.rar

{
  lib,
  pkgs,
  ...
}:

let
  macAddressPath = "/config/wifi/mac.txt";

  nvramPath = "brcm/brcmfmac43241b4-sdio.Intel Corp.-VALLEYVIEW C0 PLATFORM.txt";
  originalNvram = "${pkgs.linux-firmware}/lib/firmware/${nvramPath}";

  dynamicNvramPath = "/run/brcmfmac-nvram.txt";
  setupNvramScript = pkgs.writeShellApplication {
    name = "setup-brcmfmac-nvram";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      kmod
    ];
    text = ''
      mac_raw="$(tr -d '\n' < '${macAddressPath}')"
      mac_colons="$(printf '%s' "$mac_raw" | sed 's/../&:/g; s/:$//')"

      mkdir -p "$(dirname '${dynamicNvramPath}')"
      sed "s/00:90:4c:c5:12:38/$mac_colons/g" '${originalNvram}' > '${dynamicNvramPath}'

      exec modprobe --ignore-install brcmfmac "$@"
    '';
  };
  brcmfmac-nvram-firmware = pkgs.runCommand "brcmfmac-nvram-firmware" {
    compressFirmware = false;
    meta = {
      license = lib.licenses.gpl2Only;
    };
  } ''
    mkdir -p "$out/lib/firmware/$(dirname '${nvramPath}')"
    ln -sf '${dynamicNvramPath}' "$out/lib/firmware/${nvramPath}"
  '';
in
{
  boot.extraModprobeConfig = ''
    install brcmfmac ${lib.getExe setupNvramScript} $CMDLINE_OPTS
  '';
  hardware.firmware = [ brcmfmac-nvram-firmware ];
}
