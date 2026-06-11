FLAKE := $(shell pwd)

.PHONY: \
	darwin linux hades kratos \
	sync-darwin sync-linux sync-hades sync-kratos \
	update push pull check doctor rebuild \
	nvim-sync nvim-clean nvim-reset \
	help

# ─────────────────────────────────────────────────────────────
# System rebuilds
# ─────────────────────────────────────────────────────────────

darwin:
	sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake $(FLAKE)\#darwin-workstation

linux:
	nix run home-manager -- switch --flake $(FLAKE)\#linux-workstation

hades: darwin
kratos: linux

rebuild:
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		$(MAKE) darwin; \
	else \
		$(MAKE) linux; \
	fi

# ─────────────────────────────────────────────────────────────
# Sync
# ─────────────────────────────────────────────────────────────

pull:
	git pull --rebase

sync-darwin: pull darwin

sync-linux: pull linux

sync-hades: sync-darwin

sync-kratos: sync-linux

# ─────────────────────────────────────────────────────────────
# Updates
# ─────────────────────────────────────────────────────────────

update:
	nix flake update

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
# Diagnostics
# ─────────────────────────────────────────────────────────────

check:
	@echo ""
	@echo "── Git ───────────────────────────────────────"
	git status

	@echo ""
	@echo "── Flake outputs ─────────────────────────────"
	@nix flake show

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

# ─────────────────────────────────────────────────────────────
# Help
# ─────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "dotfiles_nix command interface"
	@echo ""
	@echo "System rebuilds:"
	@echo "  make darwin        Apply macOS nix-darwin + Home Manager config"
	@echo "  make linux         Apply Linux Home Manager config"
	@echo "  make hades         Alias for make darwin"
	@echo "  make kratos        Alias for make linux"
	@echo "  make rebuild       Auto-detect OS and apply correct config"
	@echo ""
	@echo "Sync between machines:"
	@echo "  make pull          Pull latest Git changes with rebase"
	@echo "  make sync-darwin   Pull latest changes, then rebuild macOS"
	@echo "  make sync-linux    Pull latest changes, then rebuild Linux"
	@echo "  make sync-hades    Alias for make sync-darwin"
	@echo "  make sync-kratos   Alias for make sync-linux"
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
	@echo "Diagnostics:"
	@echo "  make check         Show Git status, flake outputs, and Neovim health"
	@echo "  make doctor        Print key tool versions and important paths"
	@echo ""
	@echo "Typical flows:"
	@echo "  Edit config -> make rebuild -> make push"
	@echo "  New machine sync -> make sync-darwin or make sync-linux"
	@echo "  Broken Neovim plugins -> make nvim-reset"
	@echo ""

