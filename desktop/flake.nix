{
  description = "NixOS configuration for EmberFlake";

  inputs = {
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    optiscaler-client.url = "github:Optiscaler-Client/Optiscaler-Client";
  };

  outputs = { self, nixpkgs, unstable, optiscaler-client }:
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
        ];
        # Expose the `unstable` flake input inside configuration.nix,
        # so import of unstable NixOS modules by path works.
        specialArgs = {
          os-unstable = unstable;
          optiscaler-client = optiscaler-client.packages.${system}.default;
        };
      };
    };
}
