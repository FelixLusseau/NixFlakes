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
    splash.url =  "path:./modules/splash";
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, splash }@inputs:
    let
      # inherit (splash.inputs) nixpkgs;
    in {
      nixosConfigurations = {
        flnix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # Pass inputs into the NixOS module system
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/flnix.nix
            # splash.packages
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.users.felix = import ./home-manager/home.nix;
            }
          ];
        };
      };
    };
}
