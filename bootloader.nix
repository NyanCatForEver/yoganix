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

    # You have to copy efilinux.efi to /boot/EFI/Intel/ (XBOOTLDR partition) for Android dual boot to work.
    # systemd-boot will NOT look in /efi/ !
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

  system.preSwitchChecks.set-xbootldr-part-type =
    let
      xbootldrDevice = config.fileSystems.${config.boot.loader.systemd-boot.xbootldrMountPoint}.device;
      script = pkgs.writeShellApplication {
        name = "set-xbootldr-part-type";
        runtimeInputs = with pkgs; [
          coreutils
          util-linux
          gptfdisk
        ];
        text = ''
          [ -e "${xbootldrDevice}" ] || exit 0

          XBOOTLDR=bc13c2ff-59e6-4262-a352-b275fd6f7172

          part=$(readlink -f "${xbootldrDevice}")
          disk=/dev/$(lsblk -no PKNAME "$part")
          partnum=$(cat "/sys/class/block/$(basename "$part")/partition")

          if [ "$(lsblk -no PARTTYPE "$part")" != "$XBOOTLDR" ]; then
            echo "Changing partition type of ${xbootldrDevice} to XBOOTLDR"
            sgdisk --typecode="$partnum:$XBOOTLDR" "$disk"
          fi
        '';
      };
    in
    ''
      case "$2" in
        switch|boot) ${lib.getExe script} ;;
        *) exit 0 ;;
      esac
    '';
}
