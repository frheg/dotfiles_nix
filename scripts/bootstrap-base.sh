#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  bootstrap-base.sh
#
#  Quick-install for the "base" tier (zsh, tmux, a fully-LSP'd neovim, and
#  core CLI tools — see home/base.nix) on any macOS, Linux, or WSL machine.
#  No flake.nix registry entry needed: this builds a throwaway flake around
#  home/base.nix and points Home Manager at it directly, detecting the
#  current user/platform at run time.
#
#  Idempotent — safe to re-run (e.g. after `git pull` to pick up changes).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_MODULE="$REPO_ROOT/home/base.nix"

if [ ! -f "$BASE_MODULE" ]; then
  echo "error: $BASE_MODULE not found — run this from inside a clone of dotfiles_nix." >&2
  exit 1
fi

for bin in curl git; do
  if ! command -v "$bin" &>/dev/null; then
    echo "error: '$bin' is required but not found on PATH — install it first." >&2
    exit 1
  fi
done

case "$(uname -s)" in
  Darwin) SYSTEM="aarch64-darwin" ;;
  Linux)
    case "$(uname -m)" in
      aarch64|arm64) SYSTEM="aarch64-linux" ;;
      *)             SYSTEM="x86_64-linux" ;;
    esac
    ;;
  *) echo "error: unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

BASE_USER="${USER:-$(whoami)}"
echo "==> Platform: $SYSTEM   User: $BASE_USER"

# ── Nix ──────────────────────────────────────────────────────────────────────
if command -v nix &>/dev/null; then
  echo "==> Nix already installed — skipping."
else
  echo "==> Installing Nix (Determinate installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
  echo ""
  echo "  Nix installed. Open a new terminal and re-run this script to continue."
  exit 0
fi

# ── Throwaway flake wrapping home/base.nix ──────────────────────────────────
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

cat > "$WORKDIR/flake.nix" <<EOF
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "$SYSTEM";
        config.allowUnfree = true;
      };
      extraSpecialArgs = { user = "$BASE_USER"; };
      modules = [ $BASE_MODULE ];
    };
  };
}
EOF

echo "==> Applying base tier via Home Manager..."
nix --extra-experimental-features "nix-command flakes" run home-manager -- switch --flake "$WORKDIR#default"

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  Done. base tier applied for $BASE_USER on $SYSTEM."
echo ""
echo "  This didn't touch flake.nix — nothing to commit. If this machine"
echo "  should become a permanent, tracked entry instead, run:"
echo "    ./scripts/new-machine.sh"
echo "══════════════════════════════════════════════════════════════════"
