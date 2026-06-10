#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  bootstrap-linux.sh
#  Run ONCE on a new Kubuntu machine before `home-manager switch`.
#  Installs system-level packages Nix home-manager cannot/should not manage.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo "==> Updating apt..."
sudo apt update && sudo apt upgrade -y

# ── Core system tools ────────────────────────────────────────────────────────
echo "==> Installing core system tools..."
sudo apt install -y \
  build-essential \
  curl \
  git \
  openssh-server \
  ca-certificates \
  gnupg \
  lsb-release \
  zsh

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "==> Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# ── Docker (official Docker repo) ────────────────────────────────────────────
echo "==> Setting up Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
sudo usermod -aG docker "$USER"
echo "  Docker installed. Group change takes effect on next login."

# ── Tailscale ─────────────────────────────────────────────────────────────────
echo "==> Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
echo "  Run: sudo tailscale up"

# ── NVIDIA (manual — version depends on your GPU) ─────────────────────────────
echo ""
echo "==> NVIDIA drivers — install manually (DO NOT use Nix for these):"
echo "    sudo ubuntu-drivers autoinstall"
echo "    — or specific version —"
echo "    sudo apt install nvidia-driver-595-open nvidia-container-toolkit"
echo "    sudo apt install linux-modules-nvidia-595-open-generic"
echo ""

# ── Conda (miniconda) ────────────────────────────────────────────────────────
if [ ! -d "/opt/miniconda3" ]; then
  echo "==> Installing Miniconda..."
  curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -o /tmp/miniconda.sh
  sudo bash /tmp/miniconda.sh -b -p /opt/miniconda3
  sudo chown -R "$USER:$USER" /opt/miniconda3
  rm /tmp/miniconda.sh
  echo "  Miniconda installed at /opt/miniconda3"
else
  echo "  Miniconda already present at /opt/miniconda3 — skipping."
fi

# ── NVM ───────────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.nvm" ]; then
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  echo "  NVM installed. Run: nvm install --lts"
else
  echo "  NVM already installed — skipping."
fi

# ── Nix (Determinate installer — required for home-manager) ──────────────────
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
  echo "  Nix installed. Open a new shell then continue."
else
  echo "  Nix already installed — skipping."
fi

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  Bootstrap done. Next steps:"
echo ""
echo "  1. Log out and back in (docker group + zsh default shell)"
echo "  2. Install NVIDIA drivers if not done above + reboot"
echo "  3. Install home-manager and apply config:"
echo ""
echo "     nix run home-manager -- switch \\"
echo "       --flake github:frheg/dotfiles_nix#v1s@kratos"
echo ""
echo "  4. From then on, use: make sync-kratos  (from the dotfiles_nix dir)"
echo "══════════════════════════════════════════════════════════════════"
