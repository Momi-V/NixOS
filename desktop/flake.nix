{
  description = "NixOS configuration for EmberFlake";

  inputs = {
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    moonshine.url = "github:hgaiser/moonshine";
  };

  outputs = { self, nixpkgs, unstable, moonshine }:
    let
      system = "x86_64-linux";

      # Keep old channel-era API: `pkgs.unstable.<pkg>`
      unstable-module = {
        nixpkgs.config.packageOverrides = pkgs: {
          unstable = unstable.legacyPackages.${system};
        };
      };
    in
    {
      nixosConfigurations.EmberFlake = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          unstable-module
          moonshine.nixosModules.default
        ];
        # Expose the `unstable` flake input inside configuration.nix,
        # so import of unstable NixOS modules by path works.
        specialArgs = { unstable = unstable; };
      };
    };
}
