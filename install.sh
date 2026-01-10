#!/usr/bin/env bash

set -e

# Detect OS and set VS Code directory
if [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  VSCODE_DIR="$HOME/.config/Code/User"
else
  echo "❌ Unsupported OS: $OSTYPE"
  exit 1
fi

echo "🚀 Restoring VS Code setup..."

mkdir -p "$VSCODE_DIR"

# Restore settings
if [ -f settings.json ]; then
  cp settings.json "$VSCODE_DIR/settings.json"
  echo "✅ settings.json restored"
fi

# Restore keybindings
if [ -f keybindings.json ]; then
  cp keybindings.json "$VSCODE_DIR/keybindings.json"
  echo "✅ keybindings.json restored"
fi

# Install extensions
if [ -f extensions.txt ]; then
  echo "📦 Installing extensions..."
  cat extensions.txt | xargs -L 1 code --install-extension
  echo "✅ Extensions installed ($(wc -l < extensions.txt | xargs) extensions)"
fi

echo "🎉 VS Code setup restored!"
