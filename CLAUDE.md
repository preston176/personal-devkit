# Claude Code instructions for this repo

This repo is a personal VS Code + Claude Code snapshot. People clone it onto a
fresh machine and ask an agent to "set it up for me." Your job in that scenario
is to act as a careful migrator, not an eager installer.

## Default behavior: dry run

Unless the user has explicitly said "apply" or "go ahead and install," treat
every request to import this repo as a **dry run**:

- Read files only. Do not modify anything outside this repo.
- Do not run `./install.sh`, `code --install-extension`,
  `claude mcp add`, `npx ctx7 setup`, or `/mcp` OAuth flows.
- Do not authenticate to any third party (claude.ai connectors, Composio,
  Context7, etc.).
- Produce a written plan with diffs, deltas, and the exact commands that
  *would* run. Stop and wait for approval before executing.

The canonical dry-run prompt lives in [`AGENT_PROMPT.md`](./AGENT_PROMPT.md).
If a user pastes it, follow it verbatim.

## File map

- `settings.json` — full VS Code user settings, will overwrite the target's file
- `keybindings.json` — custom shortcuts, will overwrite
- `extensions.txt` — extensions to install via `code --install-extension`
- `claude-code-config.md` — global Claude Code reference (settings, MCP servers,
  skills, rules, plugin marketplaces) with replication commands
- `install.sh` / `export.sh` — apply / snapshot scripts
- `AGENT_PROMPT.md` — the dry-run prompt users paste into an LLM

## When the user says "apply"

Walk through these in order, confirming after each:

1. Back up existing `settings.json` and `keybindings.json` to `*.backup.json`.
2. Run `./install.sh` (settings, keybindings, extensions).
3. Run `npx ctx7 setup` (installs Context7 MCP with API key + companion
   skill + rule).
4. Run the `claude mcp add` lines from `claude-code-config.md` for any
   remaining MCP servers, then guide the user through `/mcp` OAuth for each
   claude.ai connector and Composio.
5. Optionally copy `~/.claude/skills/` and `~/.claude/CLAUDE.md` from a
   source machine if the user has one.

Each step has side effects; confirm before each.

## When the user says "snapshot" or "sync my changes"

Run `./export.sh` from inside this repo, then commit and push. Do not
auto-push without confirmation.
