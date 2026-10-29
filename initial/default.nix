{
  pkgs,
  lib,
  ...
}:

{
  image.modules.rootfs = ./disk-image.nix;

  # Make the UKI as small as possible so it can fit in the ESP
  hardware.cpu.intel.updateMicrocode = lib.mkForce false;
  boot.initrd = {
    compressor = "xz";
    compressorArgs = [
      "--check=crc32"
      "--lzma2=dict=512KiB"
      "-9e"
    ];

    includeDefaultModules = false;
    systemd.package = pkgs.systemdMinimal.override {
      withQrencode = true;
      withVConsole = true;
    };
    services.lvm.enable = false;
    services.bcache.enable = false;
  };
}
