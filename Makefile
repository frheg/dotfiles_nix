
FLAKE := $(shell pwd)

.PHONY: darwin linux hades kratos sync-darwin sync-linux sync-hades sync-kratos update push pull check help

darwin:

	sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake $(FLAKE)\#darwin-workstation

linux:

	nix run home-manager -- switch --flake $(FLAKE)\#linux-workstation

hades: darwin

kratos: linux

pull:

	git pull --rebase

sync-darwin: pull darwin

sync-linux: pull linux

sync-hades: sync-darwin

sync-kratos: sync-linux

update:

	nix flake update

push:

	git add -A
	@read -p "Commit message: " msg; git commit -m "$$msg"
	git push

check:

	git status
	@echo ""
	@echo "Available flake outputs:"
	@nix flake show --allow-import-from-derivation

help:

	@echo "make darwin      apply macOS workstation config"
	@echo "make linux       apply Linux workstation config"
	@echo "make hades       alias for make darwin"
	@echo "make kratos      alias for make linux"
	@echo "make sync-darwin pull + apply macOS config"
	@echo "make sync-linux  pull + apply Linux config"
	@echo "make update      update flake.lock"
	@echo "make push        commit + push"
	@echo "make check       status + flake outputs"

