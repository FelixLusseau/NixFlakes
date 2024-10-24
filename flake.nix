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
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager }@inputs:
    let
    in {
      nixosConfigurations = {
        flnix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # Pass inputs into the NixOS module system
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/flnix.nix
            ./modules/splash
            # ./modules/shell/zsh
            # ./modules
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
                users.felix = {
                  imports = [
                    ./home-manager/home.nix
                  ];
                };
              };
            }
          ];
        };
      };
    };
}
