# vscode-setup

My VS Code + Claude Code config, versioned so I can drop it onto a fresh machine and feel at home in five minutes. Two ways in: paste a prompt into an AI agent and let it walk through the import, or run the shell scripts the old-fashioned way.

```
.
├── settings.json           ← editor settings, theme, formatters
├── keybindings.json        ← custom shortcuts
├── extensions.txt          ← every extension I use (146 of them)
├── claude-code-config.md   ← MCP servers, skills, rules, plugin marketplaces
├── install.sh              ← restore script
├── export.sh               ← snapshot script
├── AGENT_PROMPT.md         ← the dry-run prompt to paste into your LLM
└── CLAUDE.md               ← tells Claude Code how to treat this repo
```

## Option A — Import with an AI agent (dry run by default)

Clone the repo, then paste the block below into Claude Code, Cursor, Codex, Gemini CLI, or any agent with file + shell access. The agent will diff this repo against your machine and tell you **exactly what would change** — without installing a single extension, adding a single MCP server, or opening a single OAuth window.

> Apply only after you've read the plan it produces.

```text
You are helping me import a development environment from the repo
https://github.com/preston176/vscode-setup (clone it to a temp dir if it's not
already local).

This is a DRY RUN. Do not modify any file on my system, do not install any
extension, do not add any MCP server, do not start any OAuth / `/mcp` /
`ctx7 setup` flow, do not send any data to remote services. Read-only
inspection plus a written plan — that is the entire scope of this turn.

Steps:

1. Detect my OS and resolve the VS Code user directory:
   - macOS:   $HOME/Library/Application Support/Code/User
   - Linux:   $HOME/.config/Code/User
   - Windows: %APPDATA%\Code\User

2. Read every file in the repo: settings.json, keybindings.json,
   extensions.txt, claude-code-config.md, install.sh, export.sh.

3. Compare against my current machine WITHOUT changing anything:
   - Diff repo `settings.json` against my existing one.
   - Diff repo `keybindings.json` against my existing one.
   - Run `code --list-extensions` and bucket each name in `extensions.txt`
     as already_present / would_install. List extensions I have that the
     repo doesn't — those will NOT be removed.
   - Run `claude mcp list` and list which servers from
     `claude-code-config.md` are missing.
   - Check `~/.claude/skills/<name>/` for each skill listed.
   - Check `~/.claude/rules/context7.md`.
   - Check `~/.claude/plugins/marketplaces/claude-plugins-official`.

4. Produce a single report with: OS + paths, backup commands, per-file diff
   summaries, extensions delta, MCP delta, skills delta, rules/plugin delta,
   and the ordered apply plan. Mark which apply steps would open OAuth.

5. Stop. Wait for me to say "apply" before doing anything in step 4's apply
   plan.

Hard rules:
- Never run `./install.sh`, `code --install-extension`, `claude mcp add`,
  `npx ctx7 setup`, or `/mcp` during this dry run.
- Never overwrite, delete, or rename any file under
  `~/Library/Application Support/Code/User/`, `~/.config/Code/User/`,
  `~/.claude/`, or `~/.claude.json`.
- Never authenticate to claude.ai connectors, Composio, Context7, or any
  third party. If an OAuth flow would be required to "verify" something,
  describe that fact in the plan instead of starting the flow.
- If unsure whether an action is read-only, skip it and note the
  uncertainty in the plan.
```

The same prompt lives in [`AGENT_PROMPT.md`](./AGENT_PROMPT.md) if you want a permalink to share. There's also a [`CLAUDE.md`](./CLAUDE.md) — if you open this repo in Claude Code, it'll pick those instructions up automatically.

## Option B — Just run the script

```bash
git clone https://github.com/preston176/vscode-setup.git
cd vscode-setup
./install.sh                      # settings, keybindings, extensions
npx ctx7 setup                    # Context7 MCP + skill + rule (handles API key)
```

Then open [`claude-code-config.md`](./claude-code-config.md) and run the `claude mcp add` block for any remaining connectors. OAuth into them via `/mcp` inside Claude Code.

## Snapshot your changes back into the repo

```bash
./export.sh
git add -A && git commit -m "sync" && git push
```

## Requirements

- VS Code with the `code` command on your PATH
  (`Cmd+Shift+P` → `Shell Command: Install 'code' command in PATH`)
- macOS or Linux (Windows works via WSL)
- Claude Code CLI for the MCP / skills bits — optional if you only want the VS Code half

## Handy bits

Format `settings.json` before committing:

```bash
jq . settings.json > tmp && mv tmp settings.json
```

Back up before restoring (the agent dry run already prints these for you):

```bash
cp "$HOME/Library/Application Support/Code/User/settings.json" settings.backup.json
cp "$HOME/Library/Application Support/Code/User/keybindings.json" keybindings.backup.json
```

Export a specific VS Code profile instead of the default one:

```bash
code --profile MyProfile --list-extensions > profile-extensions.txt
```
