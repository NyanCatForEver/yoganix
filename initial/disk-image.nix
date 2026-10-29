{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/virtualisation/disk-size-option.nix"
    "${modulesPath}/image/file-options.nix"
  ];

  image.extension = "img";

  system.build.image = import "${modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    inherit (config.virtualisation) diskSize;
    inherit (config.image) baseName;

    partitionTableType = "none";
    format = "raw";
    installBootLoader = false;

    fsType = "ext4";
    label = "nixos";
  };
}
