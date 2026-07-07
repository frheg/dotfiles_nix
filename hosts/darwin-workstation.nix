{ pkgs, lib, user, hostName ? null, ... }: {

  # Required by current nix-darwin for user-scoped options

  system.primaryUser = user;

  # ── User (required so home-manager can derive homeDirectory) ──────────────
  users.users.${user} = {
    name  = user;
    home  = "/Users/${user}";
    shell = pkgs.zsh;
  };

  # ── Computer name ─────────────────────────────────────────────────────────
  # Left unset by default, so the machine keeps whatever name it already has
  # (System Settings > General > Sharing, set during macOS setup).
  # Pass `hostName = "some-name";` to mkDarwinSystem in flake.nix to override.
  networking = lib.mkIf (hostName != null) {
    hostName      = hostName;
    computerName  = hostName;
    localHostName = hostName;
  };

  # ── Nix settings ──────────────────────────────────────────────────────────
  # This machine uses Determinate Nix (its own daemon at
  # /usr/local/bin/determinate-nixd), which conflicts with nix-darwin's native
  # Nix management. nix-darwin aborts activation unless we opt out here.
  # See: https://github.com/nix-darwin/nix-darwin -> `nix.enable` option.
  #
  # With nix.enable = false, everything under the `nix.*` namespace is inert
  # (nix-darwin no longer writes /etc/nix/nix.conf or manages the daemon).
  # Nix settings now live where Determinate manages them:
  #   - /etc/nix/nix.conf         (Determinate-owned; already enables
  #                                 `nix-command flakes`)
  #   - /etc/nix/nix.custom.conf  (user overrides, e.g. `trusted-users`)
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  # lib.mkDefault lets nix-darwin's own platform detection win if it sets this
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  # ── System-wide fonts ─────────────────────────────────────────────────────
  # (Linux fonts are in home/default.nix via home.packages)
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    newcomputermodern
  ];

  # ── Homebrew — managed declaratively by nix-darwin ────────────────────────
  # Requires Homebrew to be pre-installed: https://brew.sh
  # cleanup = "zap" removes any cask/brew NOT listed here on each switch.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade    = true;
      cleanup = "none";
    };

    # zathura lives in a third-party tap (it's unsupported in homebrew/core on
    # macOS). Declared here so a fresh machine taps it automatically instead of
    # relying on a manual `brew tap`.
    taps = [ "zegervdv/zathura" ];

    # Fully-qualified formula names (tap/name). The same upstream repo is
    # reachable under two tap aliases on this machine — zegervdv/zathura and
    # homebrew-zathura/zathura (a Homebrew tap-migration artifact) — so a bare
    # "zathura" is ambiguous and `brew bundle` aborts. Qualifying resolves it.
    brews = [
      "zegervdv/zathura/zathura"
      "zegervdv/zathura/zathura-pdf-mupdf"
      "zegervdv/zathura/zathura-djvu"
      "zegervdv/zathura/zathura-ps"
      "zegervdv/zathura/zathura-cb"
      # opencode not yet packaged in nixpkgs
      "opencode"
    ];

    casks = [
      # Terminal + WM + input
      "ghostty"
      "aerospace"
      "karabiner-elements"
      # System utilities
      "aldente"          # battery charge limiter
      "stats"            # menu bar system stats
      "syncthing-app"    # syncthing menu bar GUI (daemon is in home/default.nix)
      "tailscale-app"     # menu bar app + CLI (was previously installed outside Nix; Homebrew renamed this cask from "tailscale")
      # Browsers
      "zen"              # Zen Browser
      # Dev tools
      "tint"             # Tailwind CSS colour picker
      # Downloads / torrents
      "motrix"
      "qbittorrent"
    ];

    masApps = {
      # Add Mac App Store apps here: "Name" = StoreID;
    };
  };

  # ── Sketchybar — user launch agent ────────────────────────────────────────
  # Reads config from ~/.config/sketchybar/sketchybarrc (managed in home/darwin.nix)
  launchd.user.agents.sketchybar = {
    serviceConfig = {
      Label            = "com.felixkratz.sketchybar";
      ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
      RunAtLoad        = true;
      KeepAlive        = true;
      # sketchybarrc and its plugin scripts call `sketchybar` (Nix-managed)
      # and `aerospace` (Homebrew cask) by bare name; launchd's default PATH
      # includes neither.
      EnvironmentVariables.PATH = "${pkgs.sketchybar}/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      StandardOutPath  = "/tmp/sketchybar.out.log";
      StandardErrorPath = "/tmp/sketchybar.err.log";
    };
  };

  # ── macOS system defaults ─────────────────────────────────────────────────
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle      = "Dark";
      ApplePressAndHoldEnabled = false;   # enables key repeat
      KeyRepeat                = 2;
      InitialKeyRepeat         = 15;
    };
    dock.autohide     = true;
    dock.show-recents = false;
    finder.AppleShowAllFiles = true;
    finder.ShowPathbar       = true;
  };

  system.stateVersion = 5;
}
