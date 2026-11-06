{
  description = "NixOS configuration for staging";

  inputs = {
    nixpkgs.url  = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };

  outputs = { self, nixpkgs, unstable }:
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
      nixosConfigurations.staging = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          unstable-override
        ];
      };
    };
}
