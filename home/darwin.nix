{ pkgs, lib, user, ... }: {

  home.username      = user;
  home.homeDirectory = lib.mkForce "/Users/${user}";


  # ── macOS-only packages ───────────────────────────────────────────────────
  home.packages = with pkgs; [
    sketchybar   # status bar (binary; launch agent is in hosts/hades.nix)
    # Note: opencode is in hosts/hades.nix homebrew.brews (not yet in nixpkgs)
  ];

  # ── macOS zsh additions ───────────────────────────────────────────────────
  programs.zsh = {
    # Ensure Homebrew is in PATH (nix-darwin also handles this, belt-and-suspenders)
    initContent = ''
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';

    shellAliases = {
      # SSH to Kratos over Tailscale
      shkrat = "ssh ${user}@kratos";
    };
  };

  # ── Karabiner ─────────────────────────────────────────────────────────────
  # JSON managed here; the Karabiner app (installed via cask) reads this file.
  home.file.".config/karabiner/karabiner.json".source = ../config/karabiner.json;

  # ── Sketchybar ────────────────────────────────────────────────────────────
  home.file.".config/sketchybar/sketchybarrc" = {
    source     = ../config/sketchybar/sketchybarrc;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/battery.sh" = {
    source     = ../config/sketchybar/plugins/battery.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/clock.sh" = {
    source     = ../config/sketchybar/plugins/clock.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/front_app.sh" = {
    source     = ../config/sketchybar/plugins/front_app.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/space.sh" = {
    source     = ../config/sketchybar/plugins/space.sh;
    executable = true;
  };
  home.file.".config/sketchybar/plugins/volume.sh" = {
    source     = ../config/sketchybar/plugins/volume.sh;
    executable = true;
  };

  # ── AeroSpace ─────────────────────────────────────────────────────────────
  # TODO: run `find ~ -name "aerospace.toml" 2>/dev/null` to locate your config,
  # then copy it to config/aerospace.toml in this repo and uncomment the line below.
  home.file.".config/aerospace/aerospace.toml".source = ../config/aerospace.toml;

  # ── Zathura ───────────────────────────────────────────────────────────────
  # zathura itself is installed via Homebrew (hosts/darwin-workstation.nix),
  # not Nix, but its config is still declarative here.
  home.file.".config/zathura/zathurarc".source = ../config/zathura/zathurarc;
}
