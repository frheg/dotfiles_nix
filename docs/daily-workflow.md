# docs/daily-workflow.md

# Daily workflow

All changes should be made inside the repository.

Never edit generated files directly in `$HOME`.

Examples:

- edit `config/tmux/tmux.conf`
- not `~/.tmux.conf`

---

# Apply configuration

## macOS

```bash
cd ~/.config/dotfiles_nix
make darwin
```

## Linux

```bash
cd ~/.config/dotfiles_nix
make linux
```

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

### macOS

```bash
make sync-darwin
```

### Linux

```bash
make sync-linux
```

---

# Adding packages

Shared package:

Edit:

```text
home/default.nix
```

Add:

```nix
home.packages = with pkgs; [
  tree
];
```

Apply configuration afterward.

---

# Adding macOS applications

Edit:

```text
hosts/darwin-workstation.nix
```

Add:

```nix
homebrew.casks = [
  "ghostty"
];
```

Apply:

```bash
make darwin
```

---

# Editing tmux

`tmux.conf` is generated from the `programs.tmux` block in `home/default.nix`
(not a raw file in `config/` — only its helper scripts under
`config/tmux/scripts/` are raw, symlinked files).

Edit:

```text
home/default.nix
```

Apply, then reload:

```bash
make darwin   # or: make linux
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
home/default.nix
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
make darwin
make linux
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
make darwin
make linux
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

