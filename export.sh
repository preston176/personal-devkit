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

echo "📦 Exporting VS Code setup..."

# Export settings
if [ -f "$VSCODE_DIR/settings.json" ]; then
  cp "$VSCODE_DIR/settings.json" settings.json
  echo "✅ settings.json exported"
fi

# Export keybindings
if [ -f "$VSCODE_DIR/keybindings.json" ]; then
  cp "$VSCODE_DIR/keybindings.json" keybindings.json
  echo "✅ keybindings.json exported"
fi

# Export extensions
code --list-extensions | sort > extensions.txt
echo "✅ extensions.txt exported ($(wc -l < extensions.txt | xargs) extensions)"

echo "🎉 VS Code setup exported successfully!"
