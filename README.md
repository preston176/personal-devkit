# vscode-setup

My VS Code config, versioned so I can drop it onto a fresh machine and feel at home in five minutes. Also includes my Claude Code setup, because the two travel together now.

## What's in here

- [`settings.json`](./settings.json) — editor settings, theme, formatters, the works
- [`keybindings.json`](./keybindings.json) — custom keyboard shortcuts
- [`extensions.txt`](./extensions.txt) — the full extension list
- [`claude-code-config.md`](./claude-code-config.md) — global Claude Code reference: skills, MCP servers, `~/.claude/settings.json`, plugin marketplaces. Copy/paste commands inside to mirror it on another machine.
- [`export.sh`](./export.sh) — snapshot your current VS Code into this repo
- [`install.sh`](./install.sh) — restore everything onto a new machine

## Restore on a new machine

```bash
git clone https://github.com/preston176/vscode-setup.git
cd vscode-setup
./install.sh
```

Then open [`claude-code-config.md`](./claude-code-config.md) and run the `claude mcp add …` block for the connectors you want.

## Snapshot your changes

```bash
./export.sh
git add -A && git commit -m "sync" && git push
```

## Requirements

- VS Code with the `code` command on your PATH
  (`Cmd+Shift+P` → `Shell Command: Install 'code' command in PATH`)
- macOS or Linux (Windows works via WSL)

## Handy bits

Format `settings.json` before committing:

```bash
jq . settings.json > tmp && mv tmp settings.json
```

Back up before restoring:

```bash
cp "$HOME/Library/Application Support/Code/User/settings.json" settings.backup.json
```

Export a specific VS Code profile:

```bash
code --profile MyProfile --list-extensions > profile-extensions.txt
```
