# Adding machines

There are two fixed, named machines — `hades` (macOS laptop) and `kratos`
(NixOS homelab desktop) — and one open-ended tier: `base`.

`hades` and `kratos` are **not** managed through a wizard or registry. If one
of them ever moves to new hardware, that's a manual edit (account name,
hostname) in `flake.nix` and, if needed, a new hardware module — not a
"register a machine" workflow.

Everything else — a random server, a WSL box, a one-off VM — uses `base`.

---

# Quick / ephemeral use (no registry entry)

```bash
cd ~/.config/dotfiles_nix
./scripts/bootstrap-base.sh
```

Installs Nix if needed, then applies `home/base.nix` (shell, tmux, full
neovim, core CLI tools) standalone — no `flake.nix` edit, no commit. Safe to
re-run any time, including after `git pull`.

---

# Registering a permanent base-only machine

If a machine should be tracked in `flake.nix` long-term (rather than
re-running the bootstrap script), use the wizard:

```bash
./scripts/new-machine.sh
```

Detects the platform, shows a default flake attribute name / account
username / nixpkgs system string, lets you accept or override each, then
inserts a `homeConfigurations."<name>" = mkBaseSystem { ... };` entry, runs
`nix flake check`, and shows you the diff before anything is committed.

Apply it:

```bash
home-manager switch --flake ~/.config/dotfiles_nix#<name>
```

---

# Growing a base-only machine into a real role

If a registered base-only machine later needs its own extras (packages,
services, casks) beyond what `base.nix` provides:

1. Copy the pattern in `home/hades.nix` or `home/kratos.nix`: create a new
   `home/<name>.nix` module with the machine-specific additions.
2. In `flake.nix`, change that machine's entry from `mkBaseSystem` to
   whichever builder fits (`mkDarwinSystem` for a new Mac,
   `mkNixosSystem` for a new NixOS box) — or keep it as standalone Home
   Manager and just add the new module to `modules = [ ... ]`.
3. If it needs system-level management (Homebrew, launchd, NixOS services),
   add a `hosts/<name>.nix` too, following `hosts/hades.nix` /
   `hosts/kratos.nix`.

This is a deliberate, manual step — not something the wizard does for you,
since it's the point where a machine stops being "just base" and starts
having a real identity worth hand-designing.

---

# New macOS machine (only if hades is replaced/retired)

## 1. Install prerequisites

Install:

- Homebrew
- Nix

## 2. Clone repository

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix
```

## 3. Update the `hades` entry in flake.nix

If this Mac replaces the previous `hades` machine, just update the `user`
(and `hostName`, if different) in the existing
`darwinConfigurations."hades" = mkDarwinSystem { ... };` line — don't create
a second entry.

## 4. Apply

```bash
sudo nix run nix-darwin -- switch --flake .#hades
```

## 5. Manual post-apply step: Zathura.app

`hosts/hades.nix` installs zathura via Homebrew, which is CLI-only by
default — no Dock icon, no Finder "Open With" PDF association. To get a real
`.app` bundle, run once per machine (not managed by Nix):

```bash
curl -fsSL https://raw.githubusercontent.com/homebrew-zathura/homebrew-zathura/refs/heads/master/convert-into-app.sh | bash
```

This copies the already-installed `zathura` binary and its plugins into
`/Applications/Zathura.app`. Re-run it after `brew upgrade zathura` to pick
up plugin/version changes.

---

# New NixOS machine (only if kratos is replaced/retired)

1. Generate a hardware config: `nixos-generate-config`, copy the result over
   `hosts/kratos-hardware.nix`.
2. Update `user`/`hostName` in the `nixosConfigurations."kratos"` entry in
   `flake.nix` if the account name changes.
3. Apply: `sudo nixos-rebuild switch --flake .#kratos`.
