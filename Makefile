FLAKE := $(shell pwd)

# Which flake attribute the two fixed machines build. Only worth overriding
# in config/local/machine.mk (gitignored) if you're testing against a fork
# or a differently-named entry.
HADES_TARGET  ?= hades
KRATOS_TARGET ?= kratos

-include config/local/machine.mk

.PHONY: hades base kratos sync-hades sync-base sync-kratos update push pull check help rollback generations gc gc-dry gc-delete-old nvim-sync yazi-sync new-machine docs status

# ─────────────────────────────────────────────────────────────
# System rebuilds
# ─────────────────────────────────────────────────────────────
hades:
	sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake $(FLAKE)\#$(HADES_TARGET)

kratos:
	sudo nixos-rebuild switch --flake $(FLAKE)\#$(KRATOS_TARGET)

# base tier: any other machine (quick installs, servers, WSL, a registered
# base-only machine). No flake attribute required — see scripts/bootstrap-base.sh.
base:
	./scripts/bootstrap-base.sh

rebuild:
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		$(MAKE) hades; \
	elif [ -e /etc/NIXOS ]; then \
		$(MAKE) kratos; \
	else \
		$(MAKE) base; \
	fi

# ─────────────────────────────────────────────────────────────
# Sync
# ─────────────────────────────────────────────────────────────
pull:
	git pull --rebase

sync-hades: pull hades

sync-kratos: pull kratos

sync-base: pull base

# ─────────────────────────────────────────────────────────────
# Updates
# ─────────────────────────────────────────────────────────────
update:
	nix --extra-experimental-features "nix-command flakes" flake update

# ─────────────────────────────────────────────────────────────
# Git helpers
# ─────────────────────────────────────────────────────────────
push:
	git add -A
	@if git diff --cached --quiet; then \
		echo "nothing to commit"; \
	else \
		read -p "Commit message: " msg; \
		git commit -m "$$msg"; \
	fi
	git push

status:
	@echo ""
	@echo "── System ───────────────────────────────────"
	@echo "Host: $$(hostname)"
	@echo "OS:   $$(uname -s)"
	@echo "User: $$(whoami)"
	@echo ""
	@echo "── Git ──────────────────────────────────────"
	@git status -sb
	@echo ""
	@echo "── Current revision ─────────────────────────"
	@git rev-parse --short HEAD
	@echo ""
	@echo "── Flake metadata ───────────────────────────"
	@nix --extra-experimental-features "nix-command flakes" flake metadata --json | jq -r '.revision // "dirty or local"'
	@echo ""
	@echo "── Generations ──────────────────────────────"
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		darwin-rebuild --list-generations | tail -n 5; \
	elif [ -e /etc/NIXOS ]; then \
		sudo nixos-rebuild --list-generations | tail -n 5; \
	else \
		home-manager generations | tail -n 5; \
	fi
	@echo ""
	@echo "── Neovim health ────────────────────────────"
	@nvim --headless '+checkhealth vim.lsp' '+checkhealth vim.treesitter' +qa >/dev/null \
		&& echo "Neovim health: OK" \
		|| echo "Neovim health: FAILED"
	@echo ""
	@echo "── Lazy plugin state ───────────────────────"
	@nvim --headless "+Lazy! check" +qa
	@echo ""
	@echo "── Nix store ───────────────────────────────"
	@du -sh /nix/store 2>/dev/null || true
	@echo ""
	@echo "── Garbage collection preview ──────────────"
	@nix --extra-experimental-features "nix-command flakes" store gc --dry-run 2>/dev/null | tail -n 10 || true

# ─────────────────────────────────────────────────────────────
# Neovim
# ─────────────────────────────────────────────────────────────
nvim-sync:
	nvim --headless "+Lazy! sync" +qa

nvim-clean:
	nvim --headless "+Lazy! clean" +qa

nvim-reset:
	rm -rf ~/.local/share/nvim
	rm -rf ~/.local/state/nvim
	rm -rf ~/.cache/nvim
	nvim

# ─────────────────────────────────────────────────────────────
# Yazi
# ─────────────────────────────────────────────────────────────
yazi-sync:
	ya pkg install

# ─────────────────────────────────────────────────────────────
# New machine
# ─────────────────────────────────────────────────────────────
new-machine:
	./scripts/new-machine.sh

# ─────────────────────────────────────────────────────────────
# Diagnostics
# ─────────────────────────────────────────────────────────────
check:
	@echo ""
	@echo "── Git ───────────────────────────────────────"
	git status
	@echo ""
	@echo "── Flake outputs ─────────────────────────────"
	@nix --extra-experimental-features "nix-command flakes" flake show
	@echo ""
	@echo "── Flake evaluation check ────────────────────"
	@nix --extra-experimental-features "nix-command flakes" flake check --no-build
	@echo ""
	@echo "── Neovim health ─────────────────────────────"
	@nvim --headless "+checkhealth" +qa || true

doctor:
	@echo ""
	@echo "── Versions ──────────────────────────────────"
	@echo "Nix:"
	@nix --version
	@echo ""
	@echo "Home Manager:"
	@home-manager --version || true
	@echo ""
	@echo "Git:"
	@git --version
	@echo ""
	@echo "Neovim:"
	@nvim --version | head -10
	@echo ""
	@echo "── Paths ─────────────────────────────────────"
	@echo "Nvim config:"
	@echo $$HOME/.config/nvim
	@echo ""
	@echo "Nvim data:"
	@echo $$HOME/.local/share/nvim

# ─────────────────────────────────────────────
# Rollback / generations / cleanup
# ─────────────────────────────────────────────
generations:
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		echo "── nix-darwin generations ──"; \
		darwin-rebuild --list-generations; \
	elif [ -e /etc/NIXOS ]; then \
		echo "── NixOS generations ──"; \
		sudo nixos-rebuild --list-generations; \
	else \
		echo "── Home Manager generations ──"; \
		home-manager generations; \
	fi

rollback:
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		echo "Rolling back nix-darwin system generation..."; \
		sudo darwin-rebuild --rollback; \
	elif [ -e /etc/NIXOS ]; then \
		echo "Rolling back NixOS system generation..."; \
		sudo nixos-rebuild switch --rollback; \
	else \
		echo "Home Manager rollback is manual."; \
		echo ""; \
		echo "Run:"; \
		echo "  home-manager generations"; \
		echo ""; \
		echo "Then activate one:"; \
		echo "  /nix/store/<generation-path>/activate"; \
	fi

# On Darwin and NixOS, system generations live in a root-owned profile
# (/nix/var/nix/profiles/system), so collecting them needs sudo. Standalone
# Home Manager (base tier) only owns a user profile, so it doesn't.
gc-dry:
	@if [[ "$$(uname)" == "Darwin" ]] || [ -e /etc/NIXOS ]; then \
		sudo nix --extra-experimental-features "nix-command flakes" store gc --dry-run; \
	else \
		nix --extra-experimental-features "nix-command flakes" store gc --dry-run; \
	fi

gc:
	@if [[ "$$(uname)" == "Darwin" ]] || [ -e /etc/NIXOS ]; then \
		sudo nix-collect-garbage; \
	else \
		nix-collect-garbage; \
	fi

gc-delete-old:
	@if [[ "$$(uname)" == "Darwin" ]] || [ -e /etc/NIXOS ]; then \
		sudo nix-collect-garbage -d; \
	else \
		nix-collect-garbage -d; \
	fi

# ─────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────
docs:
	@echo "── Documentation ─────────────────────────────"
	@find docs -type f | sort

help:
	@echo ""
	@echo "dotfiles_nix command interface"
	@echo ""
	@echo "System rebuilds:"
	@echo "  make hades         Apply hades (macOS nix-darwin + Home Manager) config"
	@echo "  make kratos        Apply kratos (full NixOS + Home Manager) config"
	@echo "  make base          Apply the base tier (any other machine — see scripts/bootstrap-base.sh)"
	@echo "  make rebuild       Auto-detect OS and apply correct config"
	@echo ""
	@echo "Sync between machines:"
	@echo "  make pull          Pull latest Git changes with rebase"
	@echo "  make sync-hades    Pull latest changes, then rebuild hades"
	@echo "  make sync-kratos   Pull latest changes, then rebuild kratos"
	@echo "  make sync-base     Pull latest changes, then re-apply the base tier"
	@echo ""
	@echo "Updates:"
	@echo "  make update        Update flake.lock inputs"
	@echo ""
	@echo "Git:"
	@echo "  make push          Add all changes, commit interactively, push"
	@echo ""
	@echo "Neovim maintenance:"
	@echo "  make nvim-sync     Run Lazy sync headlessly"
	@echo "  make nvim-clean    Run Lazy clean headlessly"
	@echo "  make nvim-reset    Delete Neovim cache/state/data and reopen Neovim"
	@echo ""
	@echo "Yazi maintenance:"
	@echo "  make yazi-sync     Fetch yazi flavors/plugins declared in package.toml"
	@echo ""
	@echo "New machine:"
	@echo "  make new-machine   Interactive wizard to register a new base-only machine in flake.nix"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make check         Show Git status, flake outputs/eval check, and Neovim health"
	@echo "  make doctor        Print key tool versions and important paths"
	@echo ""
	@echo "Typical flows:"
	@echo "  Edit config -> make rebuild -> make push"
	@echo "  New machine sync -> make sync-hades, make sync-kratos, or make sync-base"
	@echo "  Broken Neovim plugins -> make nvim-reset"
	@echo ""
	@echo "Rollback / cleanup:"
	@echo "  make generations   List nix-darwin or Home Manager generations"
	@echo "  make rollback      Roll back macOS automatically; print Linux HM rollback instructions"
	@echo "  make gc-dry        Show what Nix garbage collection would remove"
	@echo "  make gc            Run safe garbage collection without deleting generation history"
	@echo "  make gc-delete-old Delete old generations and remove rollback history"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs          List repository documentation"
	@echo ""
	@echo "Status / diagnostics:"
	@echo "  make status        Full repository + system state overview"
