# README.md

# dotfiles_nix

Declarative multi-platform environment using:

- Nix flakes
- Home Manager
- nix-darwin

Three tiers:

- **base** — cross-platform CLI foundation (shell, tmux, full neovim, core
  tools). No fixed machine name — quick-install anywhere via a script.
- **hades** — the macOS laptop. base + macOS extras.
- **kratos** — the NixOS homelab desktop. base + homelab extras.

---

# Daily usage

## Apply config

### hades (macOS)

```bash
cd ~/.config/dotfiles_nix
make hades
```

### kratos (NixOS)

```bash
cd ~/.config/dotfiles_nix
make kratos
```

### Anywhere else (base tier)

```bash
cd ~/.config/dotfiles_nix
make base
```

---

# Sync changes between machines

## Push changes

```bash
git add -A
git commit -m "describe change"
git push
```

Or:

```bash
make push
```

---

## Pull and apply

```bash
make sync-hades    # hades
make sync-kratos   # kratos
make sync-base     # anywhere else
```

---

# Common tasks

## Add package

Shared everywhere — edit:

```text
home/base.nix
```

hades-only or kratos-only — edit `home/hades.nix`/`hosts/hades.nix` or
`home/kratos.nix`/`hosts/kratos.nix` respectively.

Apply config afterward.

---

## Add macOS app

Edit:

```text
hosts/hades.nix
```

Add cask to:

```nix
homebrew.casks = [ ];
```

Apply:

```bash
make hades
```

---

## Edit tmux

`tmux.conf` is generated from the `programs.tmux` block in `home/base.nix`
(not a raw file in `config/` — only its helper scripts under
`config/tmux/scripts/` are raw, symlinked files).

Edit:

```text
home/base.nix
```

Apply, then reload:

```bash
make hades   # or: make kratos / make base
tmux source-file ~/.config/tmux/tmux.conf
```

---

## Edit Ghostty

Edit:

```text
config/ghostty/config
```

Restart Ghostty afterward.

---

## Update nixpkgs

```bash
make update
```

Then rebuild systems and commit `flake.lock`.

---

# Bootstrap

## hades (macOS)

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix

sudo nix run nix-darwin -- switch --flake .#hades
```

## kratos (NixOS)

```bash
sudo nixos-rebuild switch --flake .#kratos
```

## Anywhere else (base tier)

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix

./scripts/bootstrap-base.sh
```

No `flake.nix` entry required. See `docs/adding-machines.md` if you want
this machine tracked as a permanent registry entry instead.

---

# Documentation

Additional documentation:

- `docs/architecture.md`
- `docs/daily-workflow.md`
- `docs/adding-machines.md`
- `docs/trying-packages.md`
