{ pkgs, lib, user, ... }: {

  home.username = user;
  home.homeDirectory = "/home/${user}";

  # nixpkgs.config.allowUnfree is set where `pkgs` is constructed instead of
  # here: this module is shared between standalone Home Manager (Kubuntu,
  # see mkLinuxSystem in flake.nix) and full NixOS (see
  # hosts/nixos-workstation.nix), and setting it here conflicts with
  # `home-manager.useGlobalPkgs` on the NixOS side.

  # ── Linux-only packages ───────────────────────────────────────────────────
  # ghostty, discord, thunderbird, nerd-fonts are already in default.nix
  # under lib.optionals pkgs.stdenv.isLinux — add anything extra here.
  home.packages = with pkgs; [
    # RISC-V cross-compilation toolchain
    # The helpers (rvasmrun, rvgccrun) are defined in zsh config.
    # On Kubuntu you may prefer: sudo apt install gcc-riscv64-linux-gnu qemu-user
    # Uncomment to manage via Nix instead:
    # pkgsCross.riscv64-embedded.buildPackages.gcc
    # qemu
  ];

  # ── Linux zsh additions ───────────────────────────────────────────────────
  programs.zsh.initContent = ''
    # SSH agent
    if [ -z "$SSH_AUTH_SOCK" ]; then
      eval "$(ssh-agent -s)" >/dev/null
    fi

    ssh-add -l >/dev/null 2>&1 || ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1

    # opencode binary is at ~/.opencode/bin on Linux (set in profileExtra already)
    # If you ever set up xcape for key remapping, add it here:
    # command -v xcape >/dev/null && xcape -e 'Control_L=Escape' &
  '';

  # ── Syncthing — user systemd service (replaces syncthing-app cask on macOS)
  services.syncthing.enable = true;
}
