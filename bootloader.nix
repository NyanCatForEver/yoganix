{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.timeout = 0;
  boot.loader.systemd-boot = {
    enable = true;
    xbootldrMountPoint = "/boot";

    # systemd-boot does not support EXT4 XBOOTLDR partitions by default, use the EFI driver from rEFInd
    extraInstallCommands = let
      driversPath = "${config.boot.loader.efi.efiSysMountPoint}/EFI/systemd/drivers";
    in ''
      ${lib.getExe' pkgs.coreutils "mkdir"} -p ${driversPath}
      ${lib.getExe' pkgs.coreutils "cp"} ${pkgs.refind}/share/refind/drivers_x64/ext4_x64.efi ${driversPath}/ext4_x64.efi
    '';

    # You have to place efilinux.efi in /boot/EFI/Intel/ (XBOOTLDR partition) for Android dual boot to work.
    # systemd-boot will NOT look in /efi/EFI/Intel !
    extraEntries = {
      "android.conf" = ''
        title Android
        efi /EFI/Intel/efilinux.efi
        sort-key android
      '';
    };

    configurationLimit = 5;
    consoleMode = "max";
   };
}
