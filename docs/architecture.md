# docs/architecture.md

# Architecture

The repository is structured around platform roles rather than machine names.

Machines are expected to fit into one of a few categories:

- Darwin workstation
- Darwin laptop
- Linux workstation
- Linux server
- Linux ML machine

The goal is to separate:

- shared configuration
- platform-specific configuration
- host-specific overrides

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

Defines all available configurations via two builder functions,
`mkDarwinSystem` and `mkLinuxSystem`. Each known machine is a single
registry entry passing in its `user` (and, for Darwin, an optional
`hostName`) — no username or machine name is hardcoded anywhere else in the
repo. See `docs/adding-machines.md` for how to register a new machine.

Typical structure:

- `darwinConfigurations`
- `homeConfigurations`

The flake connects:

- nixpkgs
- home-manager
- nix-darwin
- platform modules

---

# home/

Contains Home Manager modules.

## default.nix

Shared configuration across all machines:

- CLI packages
- zsh
- git
- tmux
- ghostty
- shell aliases
- common environment variables

## darwin.nix

macOS-specific configuration:

- AeroSpace
- SketchyBar
- Karabiner
- Homebrew-related integration

## linux.nix

Linux-specific configuration:

- Linux GUI packages
- Syncthing service
- Linux-only environment behavior

---

# hosts/

Contains host-level nix-darwin system configuration.

Examples:

- Homebrew casks
- macOS system defaults
- fonts
- launchd services

Linux currently uses only Home Manager.

---

# config/

Raw configuration files managed declaratively.

Examples:

- tmux
- ghostty
- aerospace
- sketchybar
- karabiner

These are symlinked into the home directory by Home Manager.

---

# scripts/

Bootstrap and utility scripts.

Examples:

- Linux bootstrap
- migration helpers
- sync helpers

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

