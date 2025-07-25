#!/bin/bash
set -euo pipefail

echo "=== shared-dev-setup feature running ==="

# Default packages always installed
DEFAULT_PACKAGES=(tmux zsh fonts-powerline git sudo tree bat)

# Combine defaults with any additional packages provided via DEBIAN_PACKAGES
PACKAGES=("${DEFAULT_PACKAGES[@]}")
if [ -n "${DEBIAN_PACKAGES:-}" ]; then
  PACKAGES+=("${DEBIAN_PACKAGES[@]}")
fi

echo "📦 Installing APT packages: ${PACKAGES[*]}"
apt-get update
apt-get install -y "${PACKAGES[@]}"

# Zsh + Powerlevel10k reinstallation trigger
if [[ "${FORCEREINSTALLZSH:-false}" == "true" ]]; then
  echo "🔁 Forcing reinstallation of Oh My Zsh and Powerlevel10k"
  rm -rf "$HOME/.oh-my-zsh" "$HOME/.zshrc" "$HOME/.p10k.zsh"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🎉 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "✅ Oh My Zsh already installed — skipping."
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "🎨 Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "✅ Powerlevel10k already present — skipping."
fi

# Install MesloLGS Nerd Font if enabled
if [[ "${INSTALLNERDFONT:-false}" == "true" ]]; then
  echo "🔤 Installing MesloLGS Nerd Font..."

  if ! command -v fc-cache >/dev/null 2>&1; then
    echo "📦 Installing fontconfig for fc-cache..."
    apt-get update && apt-get install -y fontconfig
  fi

  FONT_DIR="/usr/share/fonts/MesloLGS"
  mkdir -p "$FONT_DIR"
  TEMP_ZIP="/tmp/meslo.zip"
  curl -fsSL -o "$TEMP_ZIP" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
  unzip -o "$TEMP_ZIP" -d "$FONT_DIR" >/dev/null
  fc-cache -fv >/dev/null
  rm "$TEMP_ZIP"
else
  echo "ℹ️  Nerd Font installation skipped."
fi

# Ensure .p10k.zsh is sourced from .zshrc
ZSHRC="$HOME/.zshrc"
P10K_LINE='[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh'

if ! grep -Fxq "$P10K_LINE" "$ZSHRC"; then
  echo "💡 Appending Powerlevel10k config to .zshrc"
  echo "$P10K_LINE" >> "$ZSHRC"
else
  echo "✅ .p10k.zsh sourcing already present in .zshrc"
fi

# Add tmux auto-start snippet if tmux is available and not already configured
TMUX_CHECK_LINE="tmux new-session -A -s dev"
if command -v tmux >/dev/null 2>&1 && ! grep -Fq "$TMUX_CHECK_LINE" "$ZSHRC"; then
  echo "💡 Adding tmux auto-start to .zshrc"
  cat <<'EOF' >> "$ZSHRC"
if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
  tmux new-session -A -s dev
fi
EOF
else
  echo "✅ tmux auto-start already configured or tmux missing"
fi

# Clean up APT cache
echo "🧼 Cleaning up apt cache..."
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "✅ Shared dev setup complete."
