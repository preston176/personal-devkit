# VS Code Setup

My personal VS Code setup — settings, keybindings, and extensions.

## 🚀 Quick Start

### Export your current setup
```bash
./export.sh
```

### Restore setup (on a new machine or fresh install)
```bash
./install.sh
```

## 📋 Requirements

- VS Code installed
- `code` command available in PATH

**Enable the `code` command:**
1. Open VS Code
2. Press `Cmd + Shift + P` (Mac) or `Ctrl + Shift + P` (Linux/Windows)
3. Type and select: `Shell Command: Install 'code' command in PATH`

## 🖥️ Platform Support

- ✅ macOS
- ✅ Linux
- ❌ Windows (WSL should work)

## 📦 What's Included

- `settings.json` — Editor settings, theme, font, etc.
- `keybindings.json` — Custom keyboard shortcuts
- `extensions.txt` — List of installed extensions
- `export.sh` — Export script
- `install.sh` — Restore script

## 🔄 Workflow

1. Make changes to your VS Code setup
2. Run `./export.sh` to capture changes
3. Commit and push to keep your setup versioned
4. Clone on a new machine and run `./install.sh`

## 🛠️ Tips

**Auto-format settings before committing:**
```bash
jq . settings.json > tmp && mv tmp settings.json
```

**Export a specific profile:**
```bash
code --profile MyProfile --list-extensions > profile-extensions.txt
```

**Backup before restoring:**
```bash
cp "$HOME/Library/Application Support/Code/User/settings.json" settings.backup.json
```

## 📝 License

Use freely for your own setup!
