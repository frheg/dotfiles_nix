# dotfiles_nix

Declarative workstation setup for macOS and Linux using Nix flakes, Home Manager, nix-darwin, Homebrew, and raw config files.

Current machines:

| Machine | Platform | Flake output |
|---|---|---|
| Hades | macOS Apple Silicon | `.#darwin-workstation` |
| Kratos | Linux x86_64 | `.#linux-workstation` |

Compatibility aliases are kept:

| Old name | New target |
|---|---|
| `.#Hades` | `.#darwin-workstation` |
| `.#v1s@kratos` | `.#linux-workstation` |

---

## Core model

This repo is the source of truth.

Do not edit generated files in:

```text
~/.zshrc
~/.tmux.conf
~/.config/ghostty/config
~/.config/aerospace/aerospace.toml
~/.config/karabiner/karabiner.json
~/.config/nvim/init.lua
```

Those files are symlinks created by Home Manager.

Edit files inside this repo, then rebuild.

```text
repo source files
    ↓
Nix / Home Manager
    ↓
symlinks into $HOME
    ↓
apps read normal config files
```

---

## Daily workflow

### macOS

```bash
cd ~/.config/dotfiles_nix
git pull
make darwin
```

Equivalent:

```bash
make hades
```

### Linux

```bash
cd ~/.config/dotfiles_nix
git pull
make linux
```

Equivalent:

```bash
make kratos
```

### Commit and push changes

```bash
cd ~/.config/dotfiles_nix
git add -A
git commit -m "describe change"
git push
```

Or:

```bash
make push
```

---

## Editing configs

Edit repo files only.

| Config | Edit this file |
|---|---|
| zsh | `home/default.nix` |
| aliases | `home/default.nix` |
| git | `home/default.nix` |
| packages | `home/default.nix`, `home/darwin.nix`, `home/linux.nix` |
| tmux | `config/tmux/tmux.conf` |
| tmux status scripts | `config/tmux/scripts/` |
| Ghostty | `config/ghostty/config` |
| Ghostty themes | `config/ghostty/themes/` |
| AeroSpace | `config/aerospace.toml` |
| Karabiner | `config/karabiner.json` |
| SketchyBar | `config/sketchybar/` |
| Neovim | `home/default.nix` currently |

After editing:

```bash
make darwin   # macOS
make linux    # Linux
```

---

## Adding packages

### Shared package

Edit:

```text
home/default.nix
```

Add package to:

```nix
home.packages = with pkgs; [
  tree
];
```

Apply:

```bash
make darwin
make linux
```

### Linux-only package

Edit:

```text
home/linux.nix
```

### macOS-only Nix package

Edit:

```text
home/darwin.nix
```

### macOS Homebrew formula or cask

Edit:

```text
hosts/darwin-workstation.nix
```

Formula:

```nix
homebrew.brews = [
  "zathura"
];
```

Cask:

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

## Adding a new machine

Prefer platform/role outputs over hostname-specific configs.

Use this naming style:

```text
darwin-workstation
linux-workstation
linux-ml
linux-server
darwin-work
```

Layering model:

```text
common
  ↓
OS-specific
  ↓
role-specific
  ↓
host-specific only if needed
```

Host-specific files should contain only things that are truly local to one machine, such as:

- hostname
- macOS system defaults
- Homebrew GUI apps
- hardware-specific services
- monitor/window-manager differences

Shared shell, tmux, Ghostty, Neovim, git, and CLI packages should stay common unless there is a real reason to split them.

---

## Bootstrap

### macOS

Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install Nix:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
```

Clone repo:

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix
```

Apply:

```bash
make darwin
```

### Linux

Clone repo:

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix
```

Run bootstrap:

```bash
chmod +x scripts/bootstrap-linux.sh
./scripts/bootstrap-linux.sh
```

Open a new shell, then apply:

```bash
make linux
```

---

## Repo structure

```text
dotfiles_nix/
├── flake.nix
├── flake.lock
├── Makefile
├── README.md
├── hosts/
│   └── darwin-workstation.nix
├── home/
│   ├── default.nix
│   ├── darwin.nix
│   └── linux.nix
├── config/
│   ├── aerospace.toml
│   ├── ghostty/
│   │   ├── config
│   │   └── themes/
│   ├── karabiner.json
│   ├── sketchybar/
│   └── tmux/
│       ├── tmux.conf
│       └── scripts/
└── scripts/
    └── bootstrap-linux.sh
```

---

## External tools

Some tools are intentionally not managed fully by Nix.

| Tool | Managed externally because |
|---|---|
| Conda | ML environments should remain separate from Nix Python |
| nvm | Per-project Node versions |
| SDKMAN | Per-project Java versions |
| rustup/cargo | Rust toolchain manager |
| NVIDIA drivers | Kernel-level Linux driver |
| Docker Engine | Linux system daemon |
| Tailscale | Linux system service |

Shell integration for these tools is handled in `home/default.nix`.

---

## Updating dependencies

```bash
make update
make darwin
make linux
git add flake.lock
git commit -m "update nix flake inputs"
git push
```

---

## Useful commands

```bash
make check
nix flake show
home-manager news
```

