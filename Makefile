# ── dotfiles_nix workflow ─────────────────────────────────────────────────
# Run from the repo root. All commands are idempotent.

FLAKE := $(shell pwd)

.PHONY: hades kratos update push pull sync-hades sync-kratos help

## Apply config on Hades (macOS)
hades:
	darwin-rebuild switch --flake $(FLAKE)\#Hades

## Apply config on Kratos (Linux)
kratos:
	home-manager switch --flake $(FLAKE)\#v1s@kratos

## Bump all Nix inputs to latest nixpkgs — commit flake.lock afterward
update:
	nix flake update

## Commit and push current changes
push:
	git add -A
	@read -p "Commit message: " msg; git commit -m "$$msg"
	git push

## Pull latest from GitHub
pull:
	git pull --rebase

## Pull + apply on macOS
sync-hades: pull hades

## Pull + apply on Linux
sync-kratos: pull kratos

help:
	@echo ""
	@echo "  make hades        apply config on macOS (darwin-rebuild)"
	@echo "  make kratos       apply config on Linux (home-manager)"
	@echo "  make update       bump flake.lock to latest nixpkgs"
	@echo "  make push         commit + push"
	@echo "  make sync-hades   pull + apply on macOS"
	@echo "  make sync-kratos  pull + apply on Linux"
	@echo ""
