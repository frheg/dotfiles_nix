
{

  description = "v1s declarative dotfiles — base/hades/kratos tiers";

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

    # ── Tiers ────────────────────────────────────────────────────────────────
    # base    — home/base.nix only: shell, tmux, full neovim, core CLI tools.
    #           Cross-platform. Used standalone via scripts/bootstrap-base.sh
    #           (no flake registry entry needed), or as the foundation every
    #           named machine below imports and extends.
    # hades   — the one macOS laptop. base + home/hades.nix + hosts/hades.nix.
    # kratos  — the NixOS homelab desktop. base + home/kratos.nix + hosts/kratos.nix.

    # Full nix-darwin system (hades). `user`/`hostName` stay as arguments
    # rather than hardcoded inline so the same builder can register a future
    # second Darwin machine without new plumbing — just another call below.
    mkDarwinSystem = { user, hostName ? null }: nix-darwin.lib.darwinSystem {

      system = "aarch64-darwin";

      specialArgs = { inherit user hostName; };

      modules = [

        ./hosts/hades.nix

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

            imports = [ ./home/base.nix ./home/hades.nix ];

          };

        }

      ];

    };

    # Full NixOS system (kratos). `hardwareModule` points at the machine's
    # generated hardware-configuration.nix (from `nixos-generate-config`).
    mkNixosSystem = { user, hostName ? null, hardwareModule }: nixpkgs.lib.nixosSystem {

      system = "x86_64-linux";

      specialArgs = { inherit user hostName; };

      modules = [

        ./hosts/kratos.nix

        hardwareModule

        home-manager.nixosModules.home-manager

        {

          home-manager.useGlobalPkgs = true;

          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit user; };

          home-manager.users.${user} = {

            imports = [ ./home/base.nix ./home/kratos.nix ];

          };

        }

      ];

    };

    # Standalone Home Manager on just home/base.nix — no Homebrew, no NixOS
    # modules, no role-specific extras. For a permanent-but-simple machine
    # that doesn't (yet) warrant its own hades/kratos-style extras module.
    # `system` is a full nixpkgs system string (e.g. "x86_64-linux",
    # "aarch64-darwin", "aarch64-linux") so this works for any platform Home
    # Manager supports standalone. scripts/new-machine.sh writes entries here.
    mkBaseSystem = { user, system }: home-manager.lib.homeManagerConfiguration {

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      extraSpecialArgs = { inherit user; };

      modules = [ ./home/base.nix ];

    };

  in {

    # ── hades — macOS laptop (fixed) ────────────────────────────────────────
    darwinConfigurations."hades" = mkDarwinSystem { user = "v1s"; hostName = "hades"; };

    # ── kratos — NixOS homelab desktop (fixed) ──────────────────────────────
    nixosConfigurations."kratos" = mkNixosSystem {
      user = "v1s";
      hostName = "kratos";
      hardwareModule = ./hosts/kratos-hardware.nix;
    };

    # ── base-only machines ───────────────────────────────────────────────────
    # scripts/new-machine.sh inserts new entries directly above the marker.
    # Empty by default — most quick/ephemeral use goes through
    # scripts/bootstrap-base.sh instead, which needs no entry here at all.
    homeConfigurations = {
      # NEW_BASE_MACHINE_MARKER
    };

  };

}
