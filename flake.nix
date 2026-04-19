{
  description = "FL's NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      plasma-manager,
      nix-index-database,
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      nixpkgs = nixpkgs; # Allow NixConfig to catch this Nixpkgs
      nixosModules = {
        modules = {
          # # Pass inputs into the NixOS module system
          # specialArgs = { inherit inputs; };

          imports = [
            ./modules
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
            }
            nix-index-database.nixosModules.nix-index
          ];
        };
      };
    };
}
