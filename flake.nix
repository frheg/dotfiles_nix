
{

  description = "v1s declarative dotfiles — shared macOS/Linux workstation setup";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {

      url = "github:nix-community/home-manager";

      inputs.nixpkgs.follows = "nixpkgs";

    };

    nix-darwin = {

      url = "github:lnl7/nix-darwin";

      inputs.nixpkgs.follows = "nixpkgs";

    };

  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:

  let

    user = "v1s";

    darwinWorkstation = nix-darwin.lib.darwinSystem {

      system = "aarch64-darwin";

      modules = [

        ./hosts/darwin-workstation.nix

        home-manager.darwinModules.home-manager

        {

          home-manager.useGlobalPkgs = true;

          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit user; };

          home-manager.users.${user} = {

            imports = [ ./home/default.nix ./home/darwin.nix ];

          };

        }

      ];

    };

    linuxWorkstation = home-manager.lib.homeManagerConfiguration {

      pkgs = nixpkgs.legacyPackages."x86_64-linux";

      extraSpecialArgs = { inherit user; };

      modules = [ ./home/default.nix ./home/linux.nix ];

    };

  in {

    darwinConfigurations."darwin-workstation" = darwinWorkstation;

    darwinConfigurations."Hades" = darwinWorkstation;

    homeConfigurations."linux-workstation" = linuxWorkstation;

    homeConfigurations."${user}@kratos" = linuxWorkstation;

  };

}

