# Adding machines

Machines should be grouped by role and platform.

Avoid machine-specific naming unless strictly necessary.

Good examples:

- `darwin-workstation`
- `darwin-laptop`
- `linux-workstation`
- `linux-server`
- `linux-ml`

Bad examples:

- `FredLaptop`
- `GamingRig`
- `OfficeMac`

---

# Setup wizard

```bash
./scripts/new-machine.sh
```

Interactively registers a new machine in `flake.nix`: detects the platform,
shows every currently registered machine plus detected defaults (current
`$USER`, current macOS Computer Name), lets you accept or override each
value, then inserts the new entry, runs `nix flake check`, and shows you the
diff before anything is applied or committed. It also offers to write a
gitignored `config/local/machine.mk` override so `make darwin`/`make linux`
target the right machine here.

This covers the common case only — reusing `hosts/darwin-workstation.nix` or
`home/linux.nix` with a new username/hostname. If you need a genuinely new
role (different casks, different Linux behavior), follow the manual steps
below instead.

---

# How machines are registered

`flake.nix` exposes two builder functions:

- `mkDarwinSystem { user, hostName ? null }`
- `mkLinuxSystem { user }`

`user` is the only required, machine-specific value — the account name on
that particular machine. It is passed through as a module argument, so
nothing else in the repo (`hosts/*.nix`, `home/*.nix`) hardcodes a username.

`hostName` (Darwin only) is optional. Leave it unset to keep whatever
Computer Name the Mac already has from setup. Pass a string to have Nix set
`networking.hostName` / `computerName` / `localHostName` explicitly.

Each known machine is one line at the bottom of `flake.nix`:

```nix
darwinConfigurations."darwin-workstation" = mkDarwinSystem { user = "v1s"; };
homeConfigurations."linux-workstation"    = mkLinuxSystem  { user = "v1s"; };
```

---

# New macOS machine

## 1. Install prerequisites

Install:

- Homebrew
- Nix

---

## 2. Clone repository

```bash
git clone https://github.com/frheg/dotfiles_nix ~/.config/dotfiles_nix
cd ~/.config/dotfiles_nix
```

---

## 3. Register the machine in flake.nix

If the account name on this Mac is the same as an existing entry, and the
role is the same (a workstation, using `hosts/darwin-workstation.nix`), no
changes are needed — just apply the existing `darwin-workstation` config.

Otherwise, add a new line:

```nix
darwinConfigurations."darwin-laptop" = mkDarwinSystem {
  user     = "your-account-name";
  hostName = "optional-machine-name"; # omit to keep the Mac's current name
};
```

If the new machine needs different system-level behavior (different casks,
fonts, defaults), copy `hosts/darwin-workstation.nix` to a new file (e.g.
`hosts/darwin-laptop.nix`) first, and point the new flake output at that file
instead.

---

## 4. Apply

```bash
sudo nix run nix-darwin -- switch --flake .#darwin-laptop
```

If you want to keep using `make darwin` on this machine instead of typing the
flake attribute out by hand, create a gitignored local override:

```bash
mkdir -p config/local
echo 'DARWIN_TARGET := darwin-laptop' > config/local/machine.mk
```

`config/local/` is already gitignored, so this stays machine-specific and
never gets committed.

---

## 5. Manual post-apply step: Zathura.app

`hosts/darwin-workstation.nix` installs zathura via Homebrew, which is
CLI-only by default — no Dock icon, no Finder "Open With" PDF association.
To get a real `.app` bundle so PDFs/CBZ/DJVU/PS files can be opened from
Finder, run once per machine (not managed by Nix):

```bash
curl -fsSL https://raw.githubusercontent.com/homebrew-zathura/homebrew-zathura/refs/heads/master/convert-into-app.sh | bash
```

This copies the already-installed `zathura` binary and its plugins into
`/Applications/Zathura.app`. Re-run it after `brew upgrade zathura` to pick
up plugin/version changes.

---

# New Linux machine

## 1. Bootstrap

Run bootstrap script.

```bash
./scripts/bootstrap-linux.sh
```

---

## 2. Register the machine in flake.nix

Same as macOS: if the account name matches an existing entry and the role is
the same, nothing to do. Otherwise add a new line:

```nix
homeConfigurations."linux-server" = mkLinuxSystem { user = "your-account-name"; };
```

Only create a new file under `home/` (e.g. `home/linux-server.nix`) if the
machine needs Linux behavior different from `home/linux.nix`.

---

## 3. Apply

```bash
home-manager switch --flake .#linux-server
```

---

# Machine-specific configuration

Keep machine-specific configuration minimal.

Prefer:

- shared config (`home/default.nix`)
- platform config (`home/darwin.nix`, `home/linux.nix`)
- role config (`hosts/*.nix`)

Only the `user` (and optional `hostName`) in the `flake.nix` registry should
ever be machine-specific.

Examples of what belongs in a host module:

- hardware quirks
- GUI apps
- launch agents

---

# Recommended future structure

```text
home/
├── common.nix
├── darwin-common.nix
├── linux-common.nix
├── linux-server.nix
├── linux-ml.nix
└── darwin-workstation.nix
```

This scales better once multiple systems exist.
