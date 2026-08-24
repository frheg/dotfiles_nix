# docs/daily-workflow.md

# Daily workflow

All changes should be made inside the repository.

Never edit generated files directly in `$HOME`.

Examples:

- edit `config/tmux/tmux.conf`
- not `~/.tmux.conf`

---

# Apply configuration

## hades (macOS)

```bash
cd ~/.config/dotfiles_nix
make hades
```

## kratos (NixOS)

```bash
cd ~/.config/dotfiles_nix
make kratos
```

## Anywhere else (base tier)

```bash
cd ~/.config/dotfiles_nix
make base
```

Or without cloning first — see the Bootstrap section of the README.

---

# Sync between machines

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

# Adding packages

## Shared across every machine

Edit `home/base.nix`:

```nix
home.packages = with pkgs; [
  tree
];
```

## hades-only (macOS)

Edit `home/hades.nix` (Nix-managed CLI packages) or `hosts/hades.nix`
(Homebrew casks/formulas).

## kratos-only (NixOS homelab)

Edit `home/kratos.nix` (Nix-managed CLI packages) or `hosts/kratos.nix`
(system-level services/packages).

Apply configuration afterward.

---

# Adding macOS applications

Edit:

```text
hosts/hades.nix
```

Add:

```nix
homebrew.casks = [
  "ghostty"
];
```

Apply:

```bash
make hades
```

---

# Editing tmux

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

# Editing Ghostty

Edit:

```text
config/ghostty/config
```

Restart Ghostty afterward.

---

# Editing zsh

Edit:

```text
home/base.nix
```

Apply configuration.

---

# Updating nixpkgs

Update flake inputs:

```bash
make update
```

Then:

```bash
make hades
make kratos
```

Then commit the updated `flake.lock`.

---

# Checking system state

## Git state

```bash
git status
```

## Rebuild test

```bash
make hades
make kratos
```

## Verify symlinks

```bash
ls -l ~/.zshrc
ls -l ~/.tmux.conf
```

---

# Rollback

Home Manager generations:

```bash
home-manager generations
```

Rollback:

```bash
home-manager switch --rollback
```

macOS:

```bash
darwin-rebuild --list-generations
```
