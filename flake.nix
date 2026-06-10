{
  description = "v1s dotfiles — Hades (macOS aarch64) + Kratos (Linux x86_64)";

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
  in {

    # ── macOS — Apple Silicon ─────────────────────────────────────────────────
    darwinConfigurations."Hades" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/hades.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.extraSpecialArgs = { inherit user; };
          home-manager.users.${user}    = {
            imports = [ ./home/default.nix ./home/darwin.nix ];
          };
        }
      ];
    };

    # ── Linux x86_64 — Kratos ─────────────────────────────────────────────────
    homeConfigurations."${user}@kratos" = home-manager.lib.homeManagerConfiguration {
      pkgs             = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit user; };
      modules          = [ ./home/default.nix ./home/linux.nix ];
    };

  };
}
