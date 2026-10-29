# The Broadcom Bluetooth card will work without this patch.
# However, the MAC address used will be a random one, and will be overwritten with a random one by the kernel,
# which means that you have to pair your devices again after every reboot.
#
# Even though the card somehow works without a firmware blob, it still asks for one in the kernel logs:
# Bluetooth: hci0: BCM: firmware Patch file not found, tried:
# Bluetooth: hci0: BCM: 'brcm/BCM4324B3.hcd'
# Bluetooth: hci0: BCM: 'brcm/BCM.hcd'
#
# This module provides that firmware blob, and assigns the correct MAC address, read from /config/bt/bdaddr.txt
# (otherwise the Bluetooth controller will refuse to power on with a null MAC address).

{
  pkgs,
  lib,
  ...
}:

let
  broadcom-bluetooth-driver-win = pkgs.fetchurl {
    url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2016/11/20851465_7b947f7cfea3f880fcc07ca284a6b91082d18225.cab";
    hash = "sha256-tF97G4Ldk3dFnTt72k5hyrTCuUTu7a23Qh2BqKhL0b8=";
  };
  firmwareFile = "BCM4324B3_002.004.006.0130.0161.hcd";

  firmwarePath = "brcm/BCM4324B3.hcd";
  btbcm-firmware = pkgs.runCommand "btbcm-firmware" {
    nativeBuildInputs = [ pkgs.cabextract ];
    meta = {
      license = lib.licenses.unfree;
    };
  } ''
    cabextract ${broadcom-bluetooth-driver-win}

    mkdir -p "$out/lib/firmware/$(dirname '${firmwarePath}')"
    mv '${firmwareFile}' "$out/lib/firmware/${firmwarePath}"
  '';
in
{
  hardware.firmware = [ btbcm-firmware ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="bluetooth", KERNEL=="hci0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="btbcm-public-addr.service"
  '';

  systemd.services.btbcm-public-addr = {
    description = "Assign public address to Bluetooth controller";
    unitConfig.ConditionPathExists = "/config/bt/bd_addr.conf";
    path = [ pkgs.bluez pkgs.gnugrep ];
    serviceConfig.Type = "oneshot";
    script = ''
      if btmgmt --index 0 info | grep -q 'addr 00:00:00:00:00:00'; then
        btmgmt --index 0 public-addr "$(cat /config/bt/bd_addr.conf)"
      fi
    '';
  };
}
