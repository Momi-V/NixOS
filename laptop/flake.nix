{
  description = "NixOS configuration for AshFlake";

  inputs = {
    nixpkgs.url  = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    optiscaler-client.url = "github:Optiscaler-Client/Optiscaler-Client";
  };

  outputs = { self, nixpkgs, unstable, optiscaler-client }:
    let
      system = "x86_64-linux";

      # Keep old channel-era API: `pkgs.unstable.<pkg>`
      unstable-override = {
        nixpkgs.config.packageOverrides = pkgs: {
          unstable = unstable.legacyPackages.${system};
        };
      };
    in
    {
      nixosConfigurations.AshFlake = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          unstable-override
        ];
        # Expose the `unstable` flake input inside configuration.nix,
        # so import of unstable NixOS modules by path works.
        specialArgs = {
          optiscaler-client = optiscaler-client.packages.${system}.default;
        };
      };
    };
}
