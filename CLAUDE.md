# Claude Code instructions for this repo

This repo is a personal VS Code + Claude Code snapshot. People clone it onto a
fresh machine and ask an agent to "set it up for me." Your job in that scenario
is to act as a careful migrator, not an eager installer.

## Default behavior: dry run

Unless the user has explicitly said "apply" or "go ahead and install," treat
every request to import this repo as a **dry run**:

- Read files only. Do not modify anything outside this repo.
- Do not run `scripts/install.sh`, `code --install-extension`,
  `claude mcp add`, `npx ctx7 setup`, or `/mcp` OAuth flows.
- Do not authenticate to any third party (claude.ai connectors, Composio,
  Context7, etc.).
- Do not touch the claude.ai connectors listed in `claude/config.md` under
  "Remote (claude.ai connectors — OAuth)". Those are bound to the user's
  Anthropic account, not the machine, and accounts are sometimes shared.
- Produce a written plan with diffs, deltas, and the exact commands that
  *would* run. Stop and wait for approval before executing.

The canonical dry-run prompt lives in [`agent/prompt.md`](./agent/prompt.md).
If a user pastes it, follow it verbatim.

## Folder map

```
vscode/    settings.json, keybindings.json, extensions.txt — overwritten on apply
claude/    config.md (MCP / skills / rules / plugins ref), skills.md (skill tour)
agent/     prompt.md (the dry-run prompt)
scripts/   install.sh (apply), export.sh (snapshot)
```

## When the user says "apply"

Walk through these in order, confirming after each:

1. Back up existing `settings.json` and `keybindings.json` to `*.backup.json`.
2. Run `./scripts/install.sh` (settings, keybindings, extensions).
3. Run `npx ctx7 setup` (installs Context7 MCP with API key + companion
   skill + rule).
4. Run the `claude mcp add` lines from `claude/config.md` for any **non-claude.ai**
   MCP servers (Composio + local stdio: chrome-devtools, playwright,
   terraform, firebase, excalidraw). For Composio, guide the user through
   `/mcp` OAuth. **Do not** add the claude.ai connectors — they ride with
   the Anthropic account.
5. Optionally copy `~/.claude/skills/` and `~/.claude/CLAUDE.md` from a
   source machine if the user has one.

Each step has side effects; confirm before each.

## When the user says "snapshot" or "sync my changes"

Run `./scripts/export.sh` from inside this repo, then commit and push. Do not
auto-push without confirmation.
