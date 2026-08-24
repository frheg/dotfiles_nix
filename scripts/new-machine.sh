#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  new-machine.sh — register a new permanent base-only machine in flake.nix
#
#  hades and kratos are fixed, named machines — not registered through this
#  wizard. This is for a different case: a machine you want tracked as a
#  real flake entry (rather than the ephemeral scripts/bootstrap-base.sh
#  path) but that doesn't need its own role yet — just home/base.nix.
#
#  If it later needs real extras (its own casks/services/packages), copy the
#  pattern in home/hades.nix or home/kratos.nix: add a home/<name>.nix module
#  and list it alongside home/base.nix in this machine's flake.nix entry.
#
#  Every value has a detected default shown in [brackets] — press enter to
#  accept it, or type something else.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE="$REPO_ROOT/flake.nix"

cd "$REPO_ROOT"

echo "══════════════════════════════════════════════════════════════════"
echo "  New base-only machine setup wizard"
echo "══════════════════════════════════════════════════════════════════"
echo ""
echo "Fixed machines (not managed by this wizard): hades (macOS), kratos (NixOS)."
echo ""

prompt() {
  # prompt <var> <question> <default>
  local __resultvar="$1" question="$2" default="$3" answer
  read -r -p "$question [$default]: " answer || true
  answer="${answer:-$default}"
  printf -v "$__resultvar" '%s' "$answer"
}

confirm() {
  local question="$1" answer
  read -r -p "$question [y/N]: " answer || true
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

case "$(uname -s)" in
  Darwin) DEFAULT_SYSTEM="aarch64-darwin" ;;
  Linux)
    case "$(uname -m)" in
      aarch64|arm64) DEFAULT_SYSTEM="aarch64-linux" ;;
      *)             DEFAULT_SYSTEM="x86_64-linux" ;;
    esac
    ;;
  *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac
echo "Detected system: $DEFAULT_SYSTEM"
echo ""

echo "Currently registered base-only machines:"
grep -E 'homeConfigurations\."' "$FLAKE" | sed 's/^[[:space:]]*/  /' || echo "  (none yet)"
echo ""

DEFAULT_USER="${USER:-$(whoami)}"
DEFAULT_NAME="$(hostname -s 2>/dev/null || echo new-machine)"

prompt NAME "Flake attribute name for this machine" "$DEFAULT_NAME"
prompt MACHINE_USER "Account username on this machine" "$DEFAULT_USER"
prompt SYSTEM "nixpkgs system string" "$DEFAULT_SYSTEM"

if grep -q "homeConfigurations\.\"$NAME\"" "$FLAKE"; then
  echo "error: homeConfigurations.\"$NAME\" already exists in flake.nix" >&2
  exit 1
fi

NEW_LINE="      \"$NAME\" = mkBaseSystem { user = \"$MACHINE_USER\"; system = \"$SYSTEM\"; };"
MARKER="# NEW_BASE_MACHINE_MARKER"
APPLY_CMD="home-manager switch --flake $REPO_ROOT#$NAME"

echo ""
echo "── Summary ──────────────────────────────────────────────────────────"
echo "About to add to flake.nix:"
echo "  $NEW_LINE"
echo ""
confirm "Proceed?" || { echo "Aborted. flake.nix left untouched."; exit 1; }

awk -v line="$NEW_LINE" -v marker="$MARKER" '
  index($0, marker) { print line; print; next }
  { print }
' "$FLAKE" > "$FLAKE.tmp" && mv "$FLAKE.tmp" "$FLAKE"

echo ""
echo "── Validating flake ─────────────────────────────────────────────────"
if ! nix --extra-experimental-features "nix-command flakes" flake check --no-build; then
  echo ""
  echo "error: flake check failed after edit. Reverting flake.nix." >&2
  git -C "$REPO_ROOT" checkout -- flake.nix
  exit 1
fi

echo ""
echo "── Diff ─────────────────────────────────────────────────────────────"
git -C "$REPO_ROOT" diff -- flake.nix

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  Done. Next steps:"
echo ""
echo "  1. Review the diff above"
echo "  2. Apply:"
echo "       $APPLY_CMD"
echo "  3. Commit flake.nix when you're happy with it:"
echo "       git add flake.nix && git commit -m 'Register $NAME'"
echo "══════════════════════════════════════════════════════════════════"
