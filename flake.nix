{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };
  outputs =
    { nixpkgs, nixpkgs-unstable, ... }: let
    base = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                inherit (final) config;
                inherit (final.stdenv.hostPlatform) system;
              };
            })
          ];
        }
        ./configuration.nix
      ];
    };
    initial = base.extendModules {
      modules = [
        ./initial
      ];
    };
    in {
      nixosConfigurations."yoganix" = base;
      packages.x86_64-linux.initialUki = initial.config.system.build.uki;
      packages.x86_64-linux.initialRootfs = initial.config.system.build.images.rootfs;
    };
}
