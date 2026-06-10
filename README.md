# README.md

# dotfiles_nix

Declarative multi-platform environment using:

- Nix flakes
- Home Manager
- nix-darwin

Supported platforms:

- macOS
- Linux

---

# Daily usage

## Apply config

### macOS

```bash
cd ~/.config/dotfiles_nix
make darwin
```

### Linux

```bash
cd ~/.config/dotfiles_nix
make linux
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

### macOS

```bash
make sync-darwin
```

### Linux

```bash
make sync-linux
```

---

# Common tasks

## Add package

Edit:

```text
home/default.nix
```

Apply config afterward.

---

## Add macOS app

Edit:

```text
hosts/darwin-workstation.nix
```

Add cask to:

```nix
homebrew.casks = [ ];
```

Apply:

```bash
make darwin
```

---

## Edit tmux

Edit:

```text
config/tmux/tmux.conf
```

Reload:

```bash
tmux source-file ~/.tmux.conf
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

## macOS

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix

sudo nix run nix-darwin -- switch --flake .#darwin-workstation
```

---

## Linux

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix

./scripts/bootstrap-linux.sh

home-manager switch --flake .#v1s@linux-workstation
```

---

# Documentation

Additional documentation:

- `docs/architecture.md`
- `docs/daily-workflow.md`
- `docs/adding-machines.md`

