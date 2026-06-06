#!/usr/bin/env bash

set -e

# Resolve repo root regardless of where this script is invoked from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_SRC="$REPO_ROOT/vscode"

# Detect OS and set VS Code user directory
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
if [ -f "$VSCODE_SRC/settings.json" ]; then
  cp "$VSCODE_SRC/settings.json" "$VSCODE_DIR/settings.json"
  echo "✅ settings.json restored"
fi

# Restore keybindings
if [ -f "$VSCODE_SRC/keybindings.json" ]; then
  cp "$VSCODE_SRC/keybindings.json" "$VSCODE_DIR/keybindings.json"
  echo "✅ keybindings.json restored"
fi

# Install extensions
if [ -f "$VSCODE_SRC/extensions.txt" ]; then
  echo "📦 Installing extensions..."
  cat "$VSCODE_SRC/extensions.txt" | xargs -L 1 code --install-extension
  echo "✅ Extensions installed ($(wc -l < "$VSCODE_SRC/extensions.txt" | xargs) extensions)"
fi

echo "🎉 VS Code setup restored!"
