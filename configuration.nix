{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware
    ./system.nix
    ./bootloader.nix
    ./desktop.nix
    ./distributed-builds.nix
    ./services.nix
    ./software.nix
    ./users.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
