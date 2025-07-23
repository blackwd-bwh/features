#!/bin/bash
set -euo pipefail

SOCKET_PATH="${_BUILD_ARG_SOCKETPATH:-/root/.ssh/ssh-agent.sock}"
KEY_LIST="${_BUILD_ARG_KEYS:-}"
AGENT_ENV="/etc/profile.d/ssh-agent.sh"
CONFIG_PATH="/root/.ssh/config"
KNOWN_HOSTS="/root/.ssh/known_hosts"
DOTFILES_HOST="dotfiles"
DOTFILES_HOSTNAME="scm.bwhhg.io"
DOTFILES_PORT=7999

echo "🔐 Setting up SSH agent and configuration..."

# 1. Ensure .ssh exists and is secure
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# 2. Copy keys from /mnt/ssh if needed (safe mode)
echo "🔑 Copying keys from /mnt/ssh..."
IFS="," read -ra KEYS <<< "$KEY_LIST"
COPIED_KEYS=()

for key in "${KEYS[@]}"; do
  filename="$(basename "$key")"
  src="/mnt/ssh/$filename"
  dest="/root/.ssh/$filename"

  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
    chmod 600 "$dest"
    COPIED_KEYS+=("$dest")
    echo "✅ Copied $filename"
  else
    echo "⚠️  Missing key: $src"
  fi
done

# 3. Write agent startup logic (with copied key list)
cat <<EOF > "$AGENT_ENV"
#!/bin/bash
export SSH_AUTH_SOCK="$SOCKET_PATH"
export SSH_AGENT_PID=""

if [ ! -S "\$SSH_AUTH_SOCK" ]; then
  echo "🔐 Starting new ssh-agent at \$SSH_AUTH_SOCK"
  eval "\$(ssh-agent -a \$SSH_AUTH_SOCK)" > /dev/null
  export SSH_AGENT_PID=\$SSH_AGENT_PID
fi
EOF

for key in "${COPIED_KEYS[@]}"; do
  cat <<EOF >> "$AGENT_ENV"
if [ -f "$key" ] && ! ssh-add -l 2>/dev/null | grep -q "$key"; then
  echo "➕ Adding key: $key"
  ssh-add "$key"
fi
EOF
done

chmod +x "$AGENT_ENV"
echo "✅ SSH agent profile script created at $AGENT_ENV"

# 4. SSH config alias (dotfiles host)
if ! grep -q "Host $DOTFILES_HOST" "$CONFIG_PATH" 2>/dev/null; then
  echo "🔧 Adding SSH config for $DOTFILES_HOST"
  cat <<EOC >> "$CONFIG_PATH"
Host $DOTFILES_HOST
  HostName $DOTFILES_HOSTNAME
  Port $DOTFILES_PORT
EOC
fi

if ! ssh-keygen -F "$DOTFILES_HOSTNAME" -f "$KNOWN_HOSTS" >/dev/null 2>&1; then
  echo "🔑 Updating known_hosts for $DOTFILES_HOSTNAME"
  ssh-keyscan -p "$DOTFILES_PORT" "$DOTFILES_HOSTNAME" >> "$KNOWN_HOSTS"
fi
