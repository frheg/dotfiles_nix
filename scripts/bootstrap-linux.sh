#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  bootstrap-linux.sh
#  Idempotent — safe to run on a machine that already has some tools installed.
#  Run before the first `home-manager switch` on a new/existing Kubuntu machine.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo "==> Updating apt..."
sudo apt update && sudo apt upgrade -y

# ── Core system tools ────────────────────────────────────────────────────────
echo "==> Installing core system tools..."
sudo apt install -y \
  build-essential curl git openssh-server \
  ca-certificates gnupg lsb-release zsh

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "==> Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# ── Docker (official Docker repo) ────────────────────────────────────────────
if command -v docker &>/dev/null; then
  echo "==> Docker already installed — skipping."
else
  echo "==> Setting up Docker..."
  sudo install -m 0755 -d /etc/apt/keyrings

  # Remove conflicting key files if present (old .gpg vs new .asc)
  sudo rm -f /etc/apt/keyrings/docker.gpg /etc/apt/keyrings/docker.asc
  sudo rm -f /etc/apt/sources.list.d/docker.list

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update && sudo apt install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

  sudo usermod -aG docker "$USER"
  echo "  Docker installed. Group change takes effect on next login."
fi

# ── Tailscale ─────────────────────────────────────────────────────────────────
if command -v tailscale &>/dev/null; then
  echo "==> Tailscale already installed — skipping."
else
  echo "==> Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
  echo "  Run: sudo tailscale up"
fi

# ── NVIDIA ────────────────────────────────────────────────────────────────────
if command -v nvidia-smi &>/dev/null; then
  echo "==> NVIDIA drivers already installed — skipping."
else
  echo ""
  echo "==> NVIDIA drivers — install manually (DO NOT use Nix for these):"
  echo "    sudo ubuntu-drivers autoinstall"
fi

# ── Conda (miniconda) ────────────────────────────────────────────────────────
if [ -d "/opt/miniconda3" ]; then
  echo "==> Miniconda already present — skipping."
else
  echo "==> Installing Miniconda..."
  curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -o /tmp/miniconda.sh
  sudo bash /tmp/miniconda.sh -b -p /opt/miniconda3
  sudo chown -R "$USER:$USER" /opt/miniconda3
  rm /tmp/miniconda.sh
fi

# ── NVM ───────────────────────────────────────────────────────────────────────
if [ -d "$HOME/.nvm" ]; then
  echo "==> NVM already installed — skipping."
else
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  echo "  After logging in: nvm install --lts"
fi

# ── Nix ──────────────────────────────────────────────────────────────────────
if command -v nix &>/dev/null; then
  echo "==> Nix already installed — skipping."
else
  echo "==> Installing Nix (Determinate installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
  echo "  Open a new terminal after this completes."
fi

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  Done. Next steps:"
echo ""
echo "  1. Log out and back in (docker group + default shell)"
echo "  2. cd ~/.config/dotfiles_nix"
echo "  3. If your account name here isn't 'v1s', add an entry for it to"
echo "     flake.nix first (see docs/adding-machines.md)."
echo "  4. nix run home-manager -- switch --flake .#linux-workstation"
echo "  5. After that, use: make linux"
echo "══════════════════════════════════════════════════════════════════"
