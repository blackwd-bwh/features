#!/bin/bash
set -euo pipefail

echo "=== dotfiles-setup feature running ===" > /tmp/feature-debug.log
echo "🔧 Linking dotfiles..."

DOTFILES_DIR="/root/code/dotfiles/configs"

# Create target dirs if needed
mkdir -p /root

# Ensure lines are not duplicated
ZSHRC="/root/.zshrc"
DOTFILES_ZSHRC="$DOTFILES_DIR/.zshrc"

SOURCE_LINE="source $DOTFILES_ZSHRC"
P10K_LINE='[[ -r /root/.p10k.zsh ]] && source /root/.p10k.zsh'

touch "$ZSHRC"

if ! grep -qF "$SOURCE_LINE" "$ZSHRC" 2>/dev/null; then
  echo "$SOURCE_LINE" >> "$ZSHRC"
fi

if ! grep -qF "$P10K_LINE" "$ZSHRC" 2>/dev/null; then
  echo "$P10K_LINE" >> "$ZSHRC"
fi

# Symlink configs safely
ln -sf "$DOTFILES_DIR/.tmux.conf" /root/.tmux.conf
ln -sf "$DOTFILES_DIR/.gitconfig" /root/.gitconfig

echo "✅ Dotfiles linked"
