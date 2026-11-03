{
  description = "NixOS configuration for builder";

  inputs = {
    nixpkgs.url  = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };

  outputs = { self, nixpkgs, unstable }:
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
      nixosConfigurations.builder = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          unstable-module
        ];
      };
    };
}
