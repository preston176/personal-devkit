# vscode-setup

My VS Code + Claude Code config, versioned so I can drop it onto a fresh machine and feel at home in five minutes. Two ways in: paste a prompt into an AI agent and let it walk through the import, or run the shell scripts the old-fashioned way.

## Folder layout

```
.
├── README.md                ← you are here
├── CLAUDE.md                ← tells Claude Code how to treat this repo (dry-run-first)
│
├── vscode/                  ← everything VS Code
│   ├── settings.json        ← editor settings, theme, formatters
│   ├── keybindings.json     ← custom shortcuts
│   └── extensions.txt       ← every extension I use (146 of them)
│
├── claude/                  ← everything Claude Code
│   ├── config.md            ← MCP servers, skills, rules, plugin marketplaces
│   ├── skills.md            ← what every installed skill does
│   └── skills/              ← 5 standalone skills copied as-is (~60KB)
│
├── agent/                   ← drop-in agent prompts
│   └── prompt.md            ← the dry-run import prompt to paste into your LLM
│
└── scripts/                 ← shell automation
    ├── install.sh           ← restore vscode/ onto a new machine
    ├── install-skills.sh    ← install Claude Code skills (marketplace + standalone)
    └── export.sh            ← snapshot the live VS Code state back into vscode/
```

Each top-level folder is single-purpose, so you can grep or symlink whichever half you care about. New to Claude Code skills? Start with [`claude/skills.md`](./claude/skills.md) — it walks every one I have, grouped by purpose, with the trigger phrase that fires it.

## Option A — Import with an AI agent (dry run by default)

Clone the repo, then paste the block below into Claude Code, Cursor, Codex, Gemini CLI, or any agent with file + shell access. It diffs this repo against your machine and tells you **exactly what would change** — without installing a single extension, adding a single MCP server, or opening a single OAuth window.

> Apply only after you've read the plan it produces.

```text
You are helping me import a development environment from the repo
https://github.com/preston176/vscode-setup (clone it to a temp dir if it's not
already local).

This is a DRY RUN. Do not modify any file on my system, do not install any
extension, do not add any MCP server, do not start any OAuth / `/mcp` /
`ctx7 setup` flow, do not send any data to remote services. Read-only
inspection plus a written plan — that is the entire scope of this turn.

IMPORTANT — account-bound MCP servers:
The "Remote (claude.ai connectors — OAuth)" table in `claude/config.md`
(Apollo.io, ClickUp, Google Drive, Slack, Gmail, Microsoft 365, SignNow,
Notion, monday.com, Linear, Intercom, HubSpot, Figma, Canva, Box, Atlassian,
Asana) is bound to the Anthropic account, not the machine. Accounts are
sometimes shared. **Skip these entirely** — do not list them as "missing,"
do not generate `claude mcp add` lines, do not suggest OAuth into them.
They ride with the account; respect whatever the account owner has set up.

Repo layout:
- vscode/{settings.json, keybindings.json, extensions.txt}
- claude/{config.md, skills.md}
- scripts/{install.sh, export.sh}
- agent/prompt.md, CLAUDE.md, README.md

Steps:

1. Detect my OS and resolve the VS Code user directory:
   - macOS:   $HOME/Library/Application Support/Code/User
   - Linux:   $HOME/.config/Code/User
   - Windows: %APPDATA%\Code\User

2. Read every file in the repo under vscode/, claude/, scripts/, agent/,
   plus README.md and CLAUDE.md.

3. Compare against my current machine WITHOUT changing anything:
   - Diff vscode/settings.json against my existing one (or note "no existing file").
   - Diff vscode/keybindings.json against my existing one.
   - Run `code --list-extensions` and bucket each name in vscode/extensions.txt
     as already_present / would_install. List extensions I have that the repo
     doesn't — those will NOT be removed.
   - Run `claude mcp list`. Compare ONLY against the non-claude.ai servers
     from claude/config.md: `context7`, `composio`, and the local stdio
     servers (`chrome-devtools`, `playwright`, `terraform`, `firebase`,
     `excalidraw`). Ignore the claude.ai connector table entirely.
   - Check ~/.claude/skills/<name>/ for each skill listed in claude/skills.md.
   - Check ~/.claude/rules/context7.md.
   - Check ~/.claude/plugins/marketplaces/claude-plugins-official.

4. Produce a single report with: OS + paths, backup commands, per-file diff
   summaries, extensions delta, MCP delta (machine-scoped only — note the
   claude.ai exclusion), skills delta, rules/plugin delta, and the ordered
   apply plan. Mark whether Composio's `/mcp` OAuth would be needed. Do
   NOT include any step that touches claude.ai connectors.

5. Stop. Wait for me to say "apply" before doing anything in step 4's apply
   plan.

Hard rules:
- Never run scripts/install.sh, `code --install-extension`, `claude mcp add`,
  `npx ctx7 setup`, or `/mcp` during this dry run.
- Never overwrite, delete, or rename any file under
  ~/Library/Application Support/Code/User/, ~/.config/Code/User/,
  ~/.claude/, or ~/.claude.json.
- Never authenticate to claude.ai connectors, Composio, Context7, or any
  third party. If an OAuth flow would be required to "verify" something,
  describe that fact in the plan instead of starting the flow.
- Never touch claude.ai connector configuration. That list is off-limits —
  don't add, remove, re-auth, or even diagnose them.
- If unsure whether an action is read-only, skip it and note the
  uncertainty in the plan.
```

The same prompt lives in [`agent/prompt.md`](./agent/prompt.md) if you want a permalink. [`CLAUDE.md`](./CLAUDE.md) makes Claude Code pick up the dry-run-first behavior automatically when this repo is opened.

## Option B — Just run the script

```bash
git clone https://github.com/preston176/vscode-setup.git
cd vscode-setup
./scripts/install.sh              # settings, keybindings, extensions
./scripts/install-skills.sh       # marketplace skills (npx skills add) + standalone
npx ctx7 setup                    # Context7 MCP + skill + rule (handles API key)
```

Then open [`claude/config.md`](./claude/config.md) and run the `claude mcp add` block for any remaining non-claude.ai connectors (Composio + local stdio). OAuth into them via `/mcp` inside Claude Code.

## Snapshot your changes back into the repo

```bash
./scripts/export.sh
git add -A && git commit -m "sync" && git push
```

## Requirements

- VS Code with the `code` command on your PATH
  (`Cmd+Shift+P` → `Shell Command: Install 'code' command in PATH`)
- macOS or Linux (Windows works via WSL)
- Claude Code CLI for the MCP / skills bits — optional if you only want the VS Code half

## Handy bits

Format `vscode/settings.json` before committing:

```bash
jq . vscode/settings.json > tmp && mv tmp vscode/settings.json
```

Back up before restoring (the agent dry run already prints these for you):

```bash
cp "$HOME/Library/Application Support/Code/User/settings.json" settings.backup.json
cp "$HOME/Library/Application Support/Code/User/keybindings.json" keybindings.backup.json
```

Export a specific VS Code profile instead of the default one:

```bash
code --profile MyProfile --list-extensions > vscode/profile-extensions.txt
```
