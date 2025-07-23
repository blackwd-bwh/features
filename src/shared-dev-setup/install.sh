#!/bin/bash
set -euo pipefail

echo "=== shared-dev-setup feature running ==="

# Install requested Debian packages
if [ -n "${DEBIAN_PACKAGES:-}" ]; then
  echo "📦 Installing APT packages: ${DEBIAN_PACKAGES[*]}"
  apt-get update
  apt-get install -y "${DEBIAN_PACKAGES[@]}"
else
  echo "ℹ️  No DEBIAN_PACKAGES specified"
fi

# Zsh + Powerlevel10k reinstallation trigger
if [[ "${FORCE_REINSTALL_ZSH:-false}" == "true" ]]; then
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

# Clean up APT cache
echo "🧼 Cleaning up apt cache..."
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "✅ Shared dev setup complete."
