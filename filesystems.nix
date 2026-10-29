{
  config,
  ...
}:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "noatime" ];
      autoResize = true;
    };

    ${config.boot.loader.systemd-boot.xbootldrMountPoint} = {
      device = "/dev/disk/by-partlabel/factory";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/efi" = {
      device = "/dev/disk/by-partlabel/ESP";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
        "noatime"
      ];
    };

    "/config" = {
      device = "/dev/disk/by-partlabel/config";
      fsType = "ext4";
      options = [ "ro" ];
    };
  };
}
