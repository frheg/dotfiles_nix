{ pkgs, lib, user, ... }: {

  home.username      = user;
  home.homeDirectory = lib.mkForce "/Users/${user}";


  # ── macOS-only packages ───────────────────────────────────────────────────
  home.packages = with pkgs; [
    sketchybar   # status bar (binary; launch agent is in hosts/darwin-workstation.nix)
    blueutil     # Bluetooth CLI, used by sketchybar's bluetooth plugin
    # Note: opencode is in hosts/darwin-workstation.nix homebrew.brews (not yet in nixpkgs)

    # Docker (no Docker Desktop on macOS): colima runs the Linux VM + daemon,
    # docker-client provides the bare `docker` CLI, docker-compose adds
    # `docker compose`. Aliases (d/dc/dcu/...) already live in home/default.nix.
    # Not started automatically — run `colima start` when you need Docker.
    colima
    docker-client
    docker-compose
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
  home.file.".config/sketchybar/plugins/bluetooth.sh" = {
    source     = ../config/sketchybar/plugins/bluetooth.sh;
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

  # zathura ships as a bare Homebrew formula (CLI/GTK binary), not a cask with
  # a .app bundle, so macOS has nothing to register as a PDF handler. This
  # wraps it in a minimal .app under ~/Applications so it shows up in Finder,
  # "Open With", and can be set as the default PDF viewer.
  home.file."Applications/Zathura.app/Contents/Info.plist".source =
    ../config/darwin/zathura-app/Info.plist;
  home.file."Applications/Zathura.app/Contents/MacOS/Zathura" = {
    source     = ../config/darwin/zathura-app/Zathura;
    executable = true;
  };

  # zathura-pdf-mupdf doesn't get linked automatically by Homebrew — its
  # formula caveat requires manually symlinking the plugin into zathura's
  # plugin dir, or zathura opens a window but renders nothing (no PDF
  # backend registered). Done here so it survives reinstalls/new machines.
  home.activation.linkZathuraPdfPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x /opt/homebrew/bin/brew ]; then
      zathuraPrefix="$(/opt/homebrew/bin/brew --prefix zathura 2>/dev/null)"
      pluginPrefix="$(/opt/homebrew/bin/brew --prefix zathura-pdf-mupdf 2>/dev/null)"
      if [ -n "$zathuraPrefix" ] && [ -n "$pluginPrefix" ]; then
        mkdir -p "$zathuraPrefix/lib/zathura"
        ln -sf "$pluginPrefix/libpdf-mupdf.dylib" "$zathuraPrefix/lib/zathura/libpdf-mupdf.dylib"
      fi
    fi
  '';

  # Re-register the app with LaunchServices and set it as the default PDF
  # viewer every activation (idempotent; duti is installed via Homebrew).
  home.activation.registerZathuraApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app="$HOME/Applications/Zathura.app"
    lsregister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
    if [ -d "$app" ] && [ -x "$lsregister" ]; then
      "$lsregister" -f "$app"
    fi
    if command -v duti >/dev/null 2>&1; then
      duti -s org.pwmt.zathura com.adobe.pdf all
    fi
  '';
}
