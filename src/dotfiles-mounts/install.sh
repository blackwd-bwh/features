#!/bin/bash
set -euo pipefail

INFO_SCRIPT="/etc/profile.d/devcontainer-info.sh"
LOG_FILE="/tmp/devcontainer-info.log"

echo "🔧 Installing devcontainer-info feature..."

# Write the info-check script
cat << 'EOF' > "$INFO_SCRIPT"
#!/bin/bash
LOG_FILE="/tmp/devcontainer-info.log"

{
  echo ""
  echo "🔍 Devcontainer Mount & Feature Sanity Check"
  echo "==========================================="

  echo "👤 User: $(whoami)"
  echo "🏠 HOME: $HOME"

  echo "📁 Mounted paths:"
  for path in \
    "$HOME/.ssh/dotfiles_deploy_key" \
    "/mnt/ssh" \
    "$HOME/.aws" \
    "$HOME/.aws/sso/cache" \
    "$HOME/code/dotfiles" \
    "$HOME/.dotfiles_token"
  do
    if [ -e "$path" ]; then
      echo "✅ $path exists"
    else
      echo "❌ $path missing"
    fi
  done

  if command -v devcontainer &>/dev/null; then
    echo ""
    echo "🛠️  Devcontainer CLI detected — listing features:"
    devcontainer features list
  else
    echo ""
    echo "⚠️  Devcontainer CLI not available in this container."
  fi

  echo "✅ devcontainer-info.sh complete"
  echo ""
} | tee -a "$LOG_FILE"
EOF

chmod +x "$INFO_SCRIPT"

# ✅ Run now so the output appears during build
bash "$INFO_SCRIPT"
