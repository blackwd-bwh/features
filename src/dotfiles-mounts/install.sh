#!/bin/bash
set -euo pipefail

INFO_SCRIPT="/etc/profile.d/devcontainer-info.sh"
LOG_FILE="/tmp/devcontainer-info.log"

echo "📦 Installing devcontainer-info feature..."

# Write the info-check script to /etc/profile.d/
cat << 'EOF' > "$INFO_SCRIPT"
#!/bin/bash
LOG_FILE="/tmp/devcontainer-info.log"

{
  echo ""
  echo "🔍 Devcontainer Mount & Feature Sanity Check"
  echo "==========================================="

  echo "📁 Mounted paths:"
  for path in \
    "/root/.ssh/dotfiles_deploy_key" \
    "/mnt/ssh" \
    "/root/.aws" \
    "/root/.aws/sso/cache" \
    "/root/code/dotfiles" \
    "/root/.dotfiles_token"
  do
    if [ -e "$path" ]; then
      echo "✅ $path exists"
    else
      echo "❌ $path missing"
    fi
  done

  if command -v devcontainer &>/dev/null; then
    echo ""
    echo "🔧 Devcontainer CLI detected — listing features:"
    devcontainer features list
  else
    echo ""
    echo "⚠️  devcontainer CLI not available in this container."
  fi

  echo "✅ devcontainer-info.sh complete"
  echo ""
} | tee -a "$LOG_FILE"
EOF

# Make the script executable
chmod +x "$INFO_SCRIPT"

# Run it now (so it shows during build)
bash "$INFO_SCRIPT"
