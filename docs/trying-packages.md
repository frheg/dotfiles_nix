# docs/trying-packages.md

# Trying a package without editing the config

You don't need to add a package to `home/base.nix` and rebuild just to try
it. Use these for one-offs; only add it to the config once you've decided you
want it permanently.

---

# Temporary shell (recommended)

Drops you into a shell with the package on `PATH`. Gone when you exit —
nothing touches your profile or config.

```bash
nix shell nixpkgs#<package>
```

Multiple at once:

```bash
nix shell nixpkgs#htop nixpkgs#duf
```

---

# Run once, no shell

Runs a package's default binary a single time.

```bash
nix run nixpkgs#<package>
```

With args:

```bash
nix run nixpkgs#cowsay -- "hello"
```

---

# Older equivalent

Same idea as `nix shell`, more commonly seen in older docs/tutorials.

```bash
nix-shell -p <package>
```

---

# Find a package name first

```bash
nix search nixpkgs <term>
```

Or browse: https://search.nixos.org/packages

---

# Check if something is already installed via this config

```bash
which <binary>
nix-store -q --references $(which <binary>) | grep <package>
```

---

# Once you've decided to keep it

Add to `home/base.nix` (shared) or the relevant `hosts/*.nix` /
`home/{hades,kratos}.nix` (machine-specific) — see
[daily-workflow.md](daily-workflow.md#adding-packages) — then apply with
`make hades` / `make kratos` / `make base`.
