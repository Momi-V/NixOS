{
  description = "NixOS configuration for EmberFlake";

  inputs = {
    nixpkgs.url  = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
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
          "${unstable}/nixos/modules/services/networking/moonshine.nix"
        ];
        # Expose the `unstable` flake input inside configuration.nix,
        # so import of unstable NixOS modules by path works.
        specialArgs = {
          optiscaler-client = optiscaler-client.packages.${system}.default;
        };
      };
    };
}
