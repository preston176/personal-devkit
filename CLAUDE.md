# Claude Code instructions for this repo

This repo is a personal VS Code + Claude Code snapshot. People clone it onto a
fresh machine and ask an agent to "set it up for me." Your job in that scenario
is to act as a careful migrator, not an eager installer.

## Default behavior: dry run

Unless the user has explicitly said "apply" or "go ahead and install," treat
every request to import this repo as a **dry run**:

- Read files only. Do not modify anything outside this repo.
- Do not run `scripts/install.sh`, `scripts/install-iterm.sh` (its `--dry-run`
  mode is fine), `code --install-extension`,
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
claude/    config.md (MCP / skills / rules / plugins ref), skills.md (skill tour),
           skills/ (7 standalone skill folders bundled in-repo)
iterm2/    cli-profiles.json, env.zsh, sync-mcp.py — iTerm2 profiles with isolated CLI logins (macOS)
agent/     prompt.md (the dry-run prompt)
scripts/   install.sh (VS Code), install-skills.sh (Claude skills),
           install-iterm.sh (iTerm2 profiles, has --dry-run), export.sh
```

## When the user says "apply"

Walk through these in order, confirming after each:

1. Back up existing `settings.json` and `keybindings.json` to `*.backup.json`.
2. Run `./scripts/install.sh` (settings, keybindings, extensions).
3. Run `./scripts/install-skills.sh` (marketplace skills via `npx skills add`,
   skillfish skills via `npx skillfish add`,
   plus copying the 7 standalone skills from `claude/skills/` into
   `~/.claude/skills/`). Skips `context7-mcp` and `screen-demo` — see the
   script's footer notes.
4. Run `npx ctx7 setup` (installs Context7 MCP with API key + companion
   `context7-mcp` skill + rule).
5. Run the `claude mcp add` lines from `claude/config.md` for any **non-claude.ai**
   MCP servers (Composio + local stdio: chrome-devtools, playwright,
   terraform, firebase, excalidraw). For Composio, guide the user through
   `/mcp` OAuth. **Do not** add the claude.ai connectors — they ride with
   the Anthropic account.
6. macOS only: run `./scripts/install-iterm.sh --dry-run`, show the output,
   then run it for real. Afterwards, remind the user to set each isolated
   profile's git identity (the script prints the commands) and to log in
   per profile.

Each step has side effects; confirm before each.

## When the user says "snapshot" or "sync my changes"

Run `./scripts/export.sh` from inside this repo, then commit and push. Do not
auto-push without confirmation.
