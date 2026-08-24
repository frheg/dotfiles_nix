{ pkgs, lib, user, ... }: {

  # ── KRATOS — NixOS homelab extras ──────────────────────────────────────────
  # Imported on top of home/base.nix. home.username/homeDirectory are set
  # there, not here.
  #
  # nixpkgs.config.allowUnfree is set where `pkgs` is constructed instead of
  # here (see hosts/kratos.nix) — setting it here would conflict with
  # `home-manager.useGlobalPkgs`.

  # ── Linux-only packages ───────────────────────────────────────────────────
  # ghostty and nerd-fonts are already in base.nix under
  # lib.optionals pkgs.stdenv.isLinux — add anything extra here.
  home.packages = with pkgs; [
    # PDF viewer used by yazi's opener (config/yazi/yazi.toml). Unlike macOS
    # (Homebrew formula, needs a manual plugin symlink — see home/hades.nix),
    # nixpkgs' zathura bundles the mupdf backend at build time, so no extra
    # setup is needed.
    zathura
  ];

  # Sets zathura as the default PDF handler for whenever a graphical session
  # exists (X11/Wayland) to read it. No-op today on a display-server-less box.
  xdg.mimeApps = {
    enable = true;
    defaultApplications."application/pdf" = [ "org.pwmt.zathura.desktop" ];
  };

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
