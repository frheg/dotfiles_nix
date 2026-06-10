# docs/adding-machines.md

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

## 3. Create host module

Create:

```text
hosts/darwin-work.nix
```

Copy from existing Darwin host.

Adjust:

- hostname
- casks
- fonts
- defaults

---

## 4. Register flake output

Edit:

```text
flake.nix
```

Add:

```nix
darwinConfigurations."darwin-work" = ...
```

---

## 5. Apply

```bash
sudo nix run nix-darwin -- switch --flake .#darwin-work
```

---

# New Linux machine

## 1. Bootstrap

Run bootstrap script.

---

## 2. Create module if needed

Usually unnecessary unless machine-specific behavior exists.

Optional:

```text
home/linux-server.nix
home/linux-ml.nix
```

---

## 3. Register flake output

Edit:

```text
flake.nix
```

Add:

```nix
homeConfigurations."v1s@linux-server" = ...
```

---

## 4. Apply

```bash
home-manager switch --flake .#v1s@linux-server
```

---

# Machine-specific configuration

Keep machine-specific configuration minimal.

Prefer:

- shared config
- platform config
- role config

Only host-specific values should remain inside host modules.

Examples:

- hostname
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

