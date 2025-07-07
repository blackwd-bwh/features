#!/bin/bash
set -e

echo "🔍 Devcontainer Mount & Feature Sanity Check"
echo "==========================================="

# Check mounts
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

# Show features if devcontainer CLI is present
if command -v devcontainer &>/dev/null; then
  echo -e "\n🔧 Devcontainer CLI detected — listing features:"
  devcontainer features list
else
  echo -e "\n⚠️ devcontainer CLI not available in this container."
fi

echo "✅ devcontainer-info.sh complete"
