{ pkgs, lib, ... }: {

  networking.hostName      = "Hades";
  networking.localHostName = "Hades";

  # ── Nix settings ──────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users         = [ "root" "@admin" ];
  };

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
      cleanup    = "zap";
    };

    brews = [
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
      # Browsers
      "librewolf"
      # Dev tools
      "tint"             # Tailwind CSS colour picker
      "ngrok"
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
