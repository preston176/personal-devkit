#!/usr/bin/env bash

set -e

# Resolve repo root regardless of where this script is invoked from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_DST="$REPO_ROOT/vscode"

# Detect OS and set VS Code user directory
if [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  VSCODE_DIR="$HOME/.config/Code/User"
else
  echo "❌ Unsupported OS: $OSTYPE"
  exit 1
fi

echo "📦 Exporting VS Code setup..."

mkdir -p "$VSCODE_DST"

# Export settings
if [ -f "$VSCODE_DIR/settings.json" ]; then
  cp "$VSCODE_DIR/settings.json" "$VSCODE_DST/settings.json"
  echo "✅ settings.json exported"
fi

# Export keybindings
if [ -f "$VSCODE_DIR/keybindings.json" ]; then
  cp "$VSCODE_DIR/keybindings.json" "$VSCODE_DST/keybindings.json"
  echo "✅ keybindings.json exported"
fi

# Export extensions
code --list-extensions | sort > "$VSCODE_DST/extensions.txt"
echo "✅ extensions.txt exported ($(wc -l < "$VSCODE_DST/extensions.txt" | xargs) extensions)"

echo "🎉 VS Code setup exported successfully!"
