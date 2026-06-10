# dotfiles_nix

Unified declarative environment for **Hades** (macOS Apple Silicon) + **Kratos** (Kubuntu x86_64).

| Tool | Role |
|---|---|
| [Nix flakes](https://nixos.wiki/wiki/Flakes) | Package management, reproducible environments |
| [Home Manager](https://github.com/nix-community/home-manager) | User packages + dotfiles on both systems |
| [nix-darwin](https://github.com/lnl7/nix-darwin) | macOS system config + Homebrew Cask management |

---

## Bootstrap — new machine

### macOS (Hades)

```bash
# 1. Install Homebrew (required for GUI casks)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Nix (Determinate installer — recommended)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
# Open a new terminal after this step

# 3. Clone the repo
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix

# 4. First-time nix-darwin install
nix run nix-darwin -- switch --flake .#Hades
```

After the first run, use `make hades` or `darwin-rebuild switch --flake .#Hades`.

### Linux (Kratos)

```bash
# 1. Run the bootstrap script (apt packages, Docker, Tailscale, Nix, conda, nvm)
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix
chmod +x scripts/bootstrap-linux.sh
./scripts/bootstrap-linux.sh

# 2. Open a new shell, then apply the home-manager config
home-manager switch --flake .#v1s@kratos
```

After the first run, use `make kratos` or `home-manager switch --flake .#v1s@kratos`.

---

## Daily workflow

```
make hades        — apply config changes on macOS
make kratos       — apply config changes on Linux
make update       — bump nixpkgs to latest (then commit flake.lock)
make push         — commit + push to GitHub
make sync-hades   — git pull + apply on macOS
make sync-kratos  — git pull + apply on Linux
```

### Adding a package

1. Open `home/default.nix` (both systems) or `home/darwin.nix` / `home/linux.nix`
2. Add to `home.packages = with pkgs; [ ... your-package ... ]`
3. Apply: `make hades` or `make kratos`
4. Commit: `make push`
5. Other machine: `make sync-kratos` or `make sync-hades`

### Adding a macOS cask

1. Open `hosts/hades.nix`
2. Add to `homebrew.casks = [ ... "your-cask" ... ]`
3. Apply: `make hades`

### Changing a config (zsh, tmux, git, neovim…)

1. Edit `home/default.nix`
2. Apply: `make hades` or `make kratos`

### Updating package versions

```bash
make update       # bumps flake.lock to latest nixpkgs
make hades        # apply on Mac
make push         # commit new flake.lock
# on Linux:
make sync-kratos  # pull + apply
```

---

## Repo structure

```
dotfiles_nix/
├── flake.nix             Entry point — defines Hades + Kratos configs
├── flake.lock            Pinned package versions — always commit this
├── Makefile              Daily workflow commands
├── hosts/
│   └── hades.nix         nix-darwin: homebrew casks, fonts, launchd, system defaults
├── home/
│   ├── default.nix       Common: packages, zsh, tmux, git, neovim, ghostty
│   ├── darwin.nix        macOS additions: karabiner, sketchybar, aerospace
│   └── linux.nix         Linux additions: GUI apps, syncthing systemd service
├── scripts/
│   └── bootstrap-linux.sh  One-time setup for a new Kubuntu machine
└── config/
    ├── aerospace.toml    AeroSpace config (TODO: add yours)
    ├── karabiner.json    Karabiner key remapping
    └── sketchybar/
        ├── sketchybarrc
        └── plugins/      battery, clock, front_app, space, volume
```

---

## What Nix manages vs what stays external

### Managed by Nix
- All CLI tools (zsh, tmux, git, neovim, yazi, btop, lazygit, typst…)
- Dotfile configs (zshrc, tmux.conf, ghostty, karabiner, sketchybar…)
- **macOS:** Homebrew Casks (via nix-darwin) + system settings + fonts + launchd agents
- **Linux:** user packages + syncthing systemd service

### Managed externally — do not touch with Nix

| Tool | Location | Why |
|---|---|---|
| conda | `/opt/miniconda3` | ML envs; conflicts with Nix Python |
| nvm | `~/.nvm` | Per-project Node versions |
| SDKMAN | `~/.sdkman` | Per-project Java versions |
| rustup / cargo | `~/.cargo` | Rust toolchain manager |
| NVIDIA drivers | apt | Kernel-level; never manage with Nix |
| Docker Engine | apt (Linux) | System daemon |
| Tailscale | apt (Linux) | System service |

---

## TODOs

- [ ] **Git email:** edit `home/default.nix` → `programs.git.userEmail`
- [ ] **AeroSpace config:** run `find ~ -name "aerospace.toml" 2>/dev/null`, copy result to `config/aerospace.toml`, uncomment the line in `home/darwin.nix`
- [ ] **Neovim:** full plugin config to be set up after initial migration
- [ ] **`~/.config/zsh/binds.zsh`:** if this file exists and has content, migrate it into `home/default.nix` → `programs.zsh.initExtra`
