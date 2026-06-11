# Rollback and Generations

This repository uses Nix, Home Manager, and nix-darwin.

One of the main advantages of Nix is that rebuilds are atomic and versioned. Successful rebuilds create generations instead of overwriting the existing environment.

This allows:
- rollback to older working states
- reproducible environments
- safe experimentation
- versioned system history

---

# Core Concept

Traditional package managers mutate the system in-place.

Nix does not.

Instead, Nix:
1. builds a new environment in `/nix/store`
2. creates a new generation
3. updates a symlink/profile to point to the new generation

If the build fails:
- the current system remains untouched

If the new generation is broken:
- rollback is possible

---

# What Is a Generation?

A generation is a versioned snapshot of:
- installed packages
- symlinked configuration
- activated environment state

Example:

```text
generation 120
generation 121
generation 122 ← current
```

Rolling back means:

```text
122 -> 121
```

The older generation still exists unless garbage collection removes it.

---

# Store Paths

Nix builds immutable paths inside:

```text
/nix/store
```

Example:

```text
/nix/store/abcd1234-neovim-0.12.1
```

Nothing inside `/nix/store` is modified in-place.

New versions create entirely new paths.

This is why rollback is reliable.

---

# macOS (nix-darwin)

System generations are managed by nix-darwin.

## List generations

```bash
darwin-rebuild --list-generations
```

or:

```bash
make generations
```

Example:

```text
2026-06-11  120  current
2026-06-10  119
2026-06-08  118
```

## Rollback

Rollback one generation:

```bash
sudo darwin-rebuild --rollback
```

or:

```bash
make rollback
```

This switches the system symlink back to the previous generation.

---

# Linux (Home Manager)

Home Manager creates user-level generations.

## List generations

```bash
home-manager generations
```

or:

```bash
make generations
```

Example:

```text
2026-06-11  52  current
2026-06-10  51
2026-06-09  50
```

## Rollback

Home Manager rollback is manual.

Each generation contains an activation script.

Activate an older generation:

```bash
/nix/store/<generation-path>/activate
```

Example:

```bash
/nix/store/xyz-home-manager-generation/activate
```

`make rollback` prints instructions for this.

---

# Where Generations Live

## macOS

```text
/nix/var/nix/profiles/system-*-link
```

Current system:

```text
/run/current-system
```

## Linux Home Manager

Usually:

```text
~/.local/state/nix/profiles/home-manager
```

or:

```text
/nix/var/nix/profiles/per-user/<user>/home-manager
```

---

# Garbage Collection

Old generations remain until garbage collection removes them.

This means rollback history persists by default.

## Safe cleanup

```bash
make gc
```

Equivalent:

```bash
nix-collect-garbage
```

This removes unreachable store paths but preserves current generations.

## Dry-run cleanup

```bash
make gc-dry
```

Equivalent:

```bash
nix store gc --dry-run
```

Shows what would be deleted.

## Aggressive cleanup

```bash
make gc-delete-old
```

Equivalent:

```bash
nix-collect-garbage -d
```

This deletes old generations.

After this:
- rollback history may disappear
- older system states may become unrecoverable

Use carefully.

---

# How Long Are Generations Stored?

Indefinitely, unless:
- garbage collection removes them
- generation links are deleted

Nix itself does not automatically expire generations.

---

# Practical Workflow

## Before risky changes

```bash
git status
make generations
```

## Apply changes

macOS:

```bash
make darwin
```

Linux:

```bash
make linux
```

## Validate

```bash
make check
```

## Commit

```bash
make push
```

## Rollback if broken

macOS:

```bash
make rollback
```

Linux:

```bash
home-manager generations
/nix/store/<generation>/activate
```

---

# Viewing Current System

## Current generation symlink

macOS:

```bash
ls -l /run/current-system
```

Linux Home Manager:

```bash
ls -l ~/.local/state/nix/profiles/home-manager
```

## Current installed Neovim path

```bash
which nvim
readlink $(which nvim)
```

---

# Why Nix Rollback Is Reliable

Traditional systems:
- mutate files in-place
- overwrite dependencies
- partially fail during upgrades

Nix:
- never mutates store paths
- builds separately first
- switches atomically

This means:
- failed builds do not corrupt the active environment
- rollback is fast and deterministic
- old environments remain reproducible

---

# Repository Make Targets

## Rebuild

```bash
make darwin
make linux
```

## Sync

```bash
make sync-darwin
make sync-linux
```

## Validation

```bash
make check
```

## Plugin sync

```bash
make nvim-sync
```

## Rollback

```bash
make rollback
```

## Generations

```bash
make generations
```

## Cleanup

```bash
make gc
make gc-dry
make gc-delete-old
```

---

# Recommended Habit

Before large configuration changes:

```bash
git status
make generations
```

After successful rebuild:

```bash
make check
make push
```

If something breaks:

```bash
make rollback
```

This is one of the core advantages of using Nix-based environments.

