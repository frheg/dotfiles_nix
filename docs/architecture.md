# docs/architecture.md

# Architecture

The repository is built around three tiers, each extending the one before it:

- **base** — cross-platform CLI foundation (shell, tmux, a fully-LSP'd
  neovim, core tools). No fixed machine name. Runs anywhere via
  `scripts/bootstrap-base.sh`, or as a registered flake entry for a
  permanent-but-simple machine.
- **hades** — the one macOS laptop. base + macOS-specific extras.
- **kratos** — the NixOS homelab desktop. base + homelab-specific extras.

`hades` and `kratos` are fixed, named machines — not an open-ended registry.
Anything else uses the base tier.

---

# Current structure

```text
dotfiles_nix/
├── flake.nix
├── hosts/
├── home/
├── config/
├── scripts/
└── docs/
```

---

# flake.nix

Defines three builder functions:

- `mkDarwinSystem` — full nix-darwin system, used once for `hades`.
- `mkNixosSystem` — full NixOS system, used once for `kratos`.
- `mkBaseSystem` — standalone Home Manager on `home/base.nix` only, for any
  future machine registered under `homeConfigurations` that doesn't need a
  dedicated role.

No username or machine name is hardcoded anywhere outside `flake.nix` itself
— `user`/`hostName` are passed through as module arguments. See
`docs/adding-machines.md` for registering a new base-only machine.

---

# home/

Contains Home Manager modules.

## base.nix

The shared foundation, imported by every machine:

- shell (zsh)
- tmux
- neovim (full config, all LSPs/formatters)
- core CLI packages (navigation, search, dev, monitoring, etc.)
- git
- ghostty config, btop theme, yazi config

## hades.nix

macOS-only extras, imported on top of `base.nix`:

- AeroSpace, SketchyBar, Karabiner config
- Docker CLI (colima + docker-client + docker-compose)
- Zathura app wrapper + activation hooks

## kratos.nix

NixOS-homelab-only extras, imported on top of `base.nix`:

- Zathura (nixpkgs build)
- Syncthing service
- SSH agent shell init

---

# hosts/

Contains host-level system configuration (nix-darwin or NixOS).

## hades.nix

macOS system config: Homebrew (casks + formulas), fonts, launchd agents
(SketchyBar), macOS system defaults.

## kratos.nix / kratos-hardware.nix

Full NixOS system config: networking, boot loader, NVIDIA GPU stack,
Docker + GPU passthrough, Tailscale + SSH. `kratos-hardware.nix` is the
machine-generated hardware config (from `nixos-generate-config`) — do not
hand-edit it.

There is no `hosts/` module for the base tier — it never touches
system-level config (Homebrew, launchd, NixOS modules). That's the point:
it's safe to apply anywhere without root-level side effects beyond Nix
itself.

---

# config/

Raw configuration files managed declaratively.

Examples:

- ghostty
- aerospace
- sketchybar
- karabiner
- zathura
- yazi
- nvim (`lua/` modules only)
- tmux (helper scripts under `scripts/` only)

These are symlinked into the home directory by Home Manager via `home.file`.

Two exceptions worth knowing: `tmux.conf` and Neovim's `init.lua` are **not**
raw files here — they're generated inline from the `programs.tmux` /
`programs.neovim` blocks in `home/base.nix`. Editing anything under
`config/tmux/tmux.conf` or `config/nvim/init.lua` would have no effect, which
is why those files were removed rather than kept as stale duplicates.

---

# scripts/

- `bootstrap-base.sh` — installs Nix if needed, then applies the base tier
  standalone (no flake.nix registry entry required). The quick-install path.
- `new-machine.sh` — interactive wizard to register a new **base-only**
  permanent machine in `flake.nix`. `hades`/`kratos` are not managed by this
  wizard — they're fixed entries.

---

# Philosophy

Nix manages:

- packages
- dotfiles
- shell environment
- reproducible configuration

External tools manage:

- conda environments
- SDKMAN
- rustup
- Docker daemon
- NVIDIA drivers

Nix should not manage mutable development environments.
