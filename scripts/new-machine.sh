#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  new-machine.sh — interactive wizard to register a new machine in flake.nix
#
#  Handles the common case: reusing hosts/darwin-workstation.nix or
#  home/linux.nix with a new username / hostname. For a genuinely new role
#  (different casks, different Linux behavior), copy a host/home module by
#  hand first — see docs/adding-machines.md.
#
#  Every value has a detected default shown in [brackets] — press enter to
#  accept it, or type something else.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE="$REPO_ROOT/flake.nix"

cd "$REPO_ROOT"

echo "══════════════════════════════════════════════════════════════════"
echo "  New machine setup wizard"
echo "══════════════════════════════════════════════════════════════════"
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
  Darwin) PLATFORM="darwin" ;;
  Linux)  PLATFORM="linux" ;;
  *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac
echo "Detected platform: $PLATFORM"
echo ""

echo "Currently registered machines:"
grep -E 'darwinConfigurations\.|homeConfigurations\.' "$FLAKE" | sed 's/^[[:space:]]*/  /'
echo ""

DEFAULT_USER="${USER:-$(whoami)}"

if [ "$PLATFORM" = "darwin" ]; then
  DEFAULT_NAME="darwin-workstation"
  CURRENT_COMPUTER_NAME="$(scutil --get ComputerName 2>/dev/null || echo "unknown")"
  echo "This Mac's current Computer Name: $CURRENT_COMPUTER_NAME"
  echo "(Default is to leave it untouched — nothing renames your Mac unless"
  echo " you explicitly set an override below.)"
  echo ""

  prompt NAME "Flake attribute name for this machine" "$DEFAULT_NAME"
  prompt MACHINE_USER "macOS account username on this machine" "$DEFAULT_USER"
  prompt HOSTNAME_OVERRIDE "Computer Name override (blank = keep current)" ""

  if grep -q "darwinConfigurations\.\"$NAME\"" "$FLAKE"; then
    echo "error: darwinConfigurations.\"$NAME\" already exists in flake.nix" >&2
    exit 1
  fi

  if [ -n "$HOSTNAME_OVERRIDE" ]; then
    NEW_LINE="    darwinConfigurations.\"$NAME\" = mkDarwinSystem { user = \"$MACHINE_USER\"; hostName = \"$HOSTNAME_OVERRIDE\"; };"
  else
    NEW_LINE="    darwinConfigurations.\"$NAME\" = mkDarwinSystem { user = \"$MACHINE_USER\"; };"
  fi

  MARKER="# NEW_DARWIN_MACHINE_MARKER"
  APPLY_CMD="sudo nix run nix-darwin -- switch --flake $REPO_ROOT#$NAME"
  MAKE_VAR="DARWIN_TARGET"

else
  DEFAULT_NAME="linux-workstation"

  prompt NAME "Flake attribute name for this machine" "$DEFAULT_NAME"
  prompt MACHINE_USER "Linux account username on this machine" "$DEFAULT_USER"

  if grep -q "homeConfigurations\.\"$NAME\"" "$FLAKE"; then
    echo "error: homeConfigurations.\"$NAME\" already exists in flake.nix" >&2
    exit 1
  fi

  NEW_LINE="    homeConfigurations.\"$NAME\" = mkLinuxSystem { user = \"$MACHINE_USER\"; };"
  MARKER="# NEW_LINUX_MACHINE_MARKER"
  APPLY_CMD="home-manager switch --flake $REPO_ROOT#$NAME"
  MAKE_VAR="LINUX_TARGET"
fi

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
if ! nix flake check --no-build; then
  echo ""
  echo "error: flake check failed after edit. Reverting flake.nix." >&2
  git -C "$REPO_ROOT" checkout -- flake.nix
  exit 1
fi

echo ""
echo "── Diff ─────────────────────────────────────────────────────────────"
git -C "$REPO_ROOT" diff -- flake.nix

echo ""
if confirm "Also set this as the default for 'make $PLATFORM' on this machine?"; then
  mkdir -p "$REPO_ROOT/config/local"
  echo "$MAKE_VAR := $NAME" >> "$REPO_ROOT/config/local/machine.mk"
  echo "Wrote config/local/machine.mk (gitignored)."
fi

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  Done. Next steps:"
echo ""
echo "  1. Review the diff above (and config/local/machine.mk if written)"
echo "  2. Apply:"
echo "       $APPLY_CMD"
echo "  3. Commit flake.nix when you're happy with it:"
echo "       git add flake.nix && git commit -m 'Register $NAME'"
echo "══════════════════════════════════════════════════════════════════"
