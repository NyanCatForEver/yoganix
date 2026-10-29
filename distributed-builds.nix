{
  ...
}:

{
  # Configure your remote build machines here.
  # This is required if you want working sound,
  # otherwise you'll have to compile the kernel on the tablet itself.
  # NOTE: This is not needed if you always run nixos-rebuild remotely.
  #
  # https://wiki.nixos.org/wiki/Distributed_build
  nix.buildMachines = [

  ];
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
}
