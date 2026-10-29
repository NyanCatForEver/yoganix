{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };
  outputs =
    { nixpkgs, nixpkgs-unstable, ... }:
    {
      nixosConfigurations."yoganix" = nixpkgs.lib.nixosSystem {
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
    };
}
