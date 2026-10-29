{
  ...
}:

{
  # Configure your remote build machines here.
  # This is required if you want working sound,
  # otherwise you'll have to compile the kernel on the tablet itself.
  #
  # https://wiki.nixos.org/wiki/Distributed_build
  nix.buildMachines = [
    {
      hostName = "fednyan.local";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      supportedFeatures = [ "big-parallel" "kvm" ];
      speedFactor = 2;

      sshUser = "nixremote";
      sshKey = "/root/.ssh/nixremote";
    }
    {
      hostName = "homenix.local";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      supportedFeatures = [ "big-parallel" "kvm" ];
      speedFactor = 1;

      sshUser = "nixremote";
      sshKey = "/root/.ssh/nixremote";
    }
  ];
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
}
