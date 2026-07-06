
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

    # ── Machine builders ──────────────────────────────────────────────────
    # `user` is the only required, machine-specific value — the macOS/Linux
    # account name on that particular machine (it can differ per machine).
    # `hostName` is optional: leave it unset to keep whatever Computer
    # Name / hostname the machine already has (e.g. what you gave it during
    # macOS setup); pass a string to have Nix set it explicitly instead.
    mkDarwinSystem = { user, hostName ? null }: nix-darwin.lib.darwinSystem {

      system = "aarch64-darwin";

      specialArgs = { inherit user hostName; };

      modules = [

        ./hosts/darwin-workstation.nix

        home-manager.darwinModules.home-manager

        {

          home-manager.useGlobalPkgs = true;

          home-manager.useUserPackages = true;

          # If a real (unmanaged) file already exists where Home Manager wants
          # to place a symlink, back it up as <file>.hm-backup instead of
          # aborting activation. Lets a first switch adopt pre-existing dotfiles.
          home-manager.backupFileExtension = "hm-backup";

          home-manager.extraSpecialArgs = { inherit user; };

          home-manager.users.${user} = {

            imports = [ ./home/default.nix ./home/darwin.nix ];

          };

        }

      ];

    };

    mkLinuxSystem = { user }: home-manager.lib.homeManagerConfiguration {

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      extraSpecialArgs = { inherit user; };

      modules = [ ./home/default.nix ./home/linux.nix ];

    };

    # Full NixOS machines (system + Home Manager in one). `hardwareModule`
    # points at the machine's generated hardware-configuration.nix (from
    # `nixos-generate-config`) — required and genuinely per-machine, unlike
    # `user`/`hostName` which just default sensibly.
    mkNixosSystem = { user, hostName ? null, hardwareModule }: nixpkgs.lib.nixosSystem {

      system = "x86_64-linux";

      specialArgs = { inherit user hostName; };

      modules = [

        ./hosts/nixos-workstation.nix

        hardwareModule

        home-manager.nixosModules.home-manager

        {

          home-manager.useGlobalPkgs = true;

          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit user; };

          home-manager.users.${user} = {

            imports = [ ./home/default.nix ./home/linux.nix ];

          };

        }

      ];

    };

  in {

    # ── Darwin machines ────────────────────────────────────────────────────
    # scripts/new-machine.sh inserts new entries directly above the marker.
    darwinConfigurations."darwin-workstation" = mkDarwinSystem { user = "Fredric.Hegland"; };
    # NEW_DARWIN_MACHINE_MARKER

    # ── Linux machines (standalone Home Manager, no NixOS) ─────────────────
    # scripts/new-machine.sh inserts new entries directly above the marker.
    homeConfigurations."linux-workstation" = mkLinuxSystem { user = "Fredric.Hegland"; };
    # NEW_LINUX_MACHINE_MARKER

    # ── NixOS machines ──────────────────────────────────────────────────────
    nixosConfigurations."nixos-workstation" = mkNixosSystem {
      user = "v1s";
      hardwareModule = ./hosts/nixos-workstation-hardware.nix;
    };

  };

}
