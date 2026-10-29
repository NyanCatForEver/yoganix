{
  ...
}:

{
  imports = [
    ./hardware
    ./system.nix
    ./bootloader.nix
    ./filesystems.nix
    ./desktop.nix
    ./distributed-builds.nix
    ./services.nix
    ./software.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";
}
