# Agent import prompt (dry run)

Paste the block below into Claude Code, Cursor, Codex, Gemini CLI, or any LLM with file/shell access. It teaches the agent how to read this repo and report **exactly what would change on your machine**, without touching a single file or signing into a single service.

> **Safety guarantee:** the prompt is read-only. The agent is told not to install extensions, not to run `claude mcp add`, not to overwrite settings, and not to open OAuth flows. Apply only after you review the plan.

---

```text
You are helping me import a development environment from the repo
https://github.com/preston176/vscode-setup (clone it to a temp dir if it's not
already local).

This is a DRY RUN. Do not modify any file on my system, do not install any
extension, do not add any MCP server, do not start any OAuth / `/mcp` /
`ctx7 setup` flow, do not send any data to remote services. Read-only
inspection plus a written plan — that is the entire scope of this turn.

IMPORTANT — account-bound MCP servers:
The "Remote (claude.ai connectors — OAuth)" table in `claude-code-config.md`
(Apollo.io, ClickUp, Google Drive, Slack, Gmail, Microsoft 365, SignNow,
Notion, monday.com, Linear, Intercom, HubSpot, Figma, Canva, Box, Atlassian,
Asana) is bound to the Anthropic account, not the machine. Accounts are
sometimes shared. **Skip these entirely** in both the dry-run analysis and
the apply plan — do not list them as "missing," do not generate `claude mcp
add` lines for them, do not suggest OAuth into them. They travel with the
account on their own; respect whatever the account owner has already set up.

Steps:

1. Detect my OS and resolve the VS Code user directory:
   - macOS:   $HOME/Library/Application Support/Code/User
   - Linux:   $HOME/.config/Code/User
   - Windows: %APPDATA%\Code\User

2. Read every file in the repo:
   - settings.json
   - keybindings.json
   - extensions.txt
   - claude-code-config.md
   - install.sh, export.sh (just to understand the existing flow)

3. Compare against my current machine WITHOUT changing anything:
   - Diff repo `settings.json` against my existing one (or note "no existing file").
   - Diff repo `keybindings.json` against my existing one.
   - Run `code --list-extensions` and compute: how many in `extensions.txt`
     are already installed, how many would be newly installed, and any I have
     that aren't in the repo (those would NOT be removed).
   - Run `claude mcp list`. Compare ONLY against the non-claude.ai servers
     from `claude-code-config.md`: `context7`, `composio`, and the local
     stdio servers (`chrome-devtools`, `playwright`, `terraform`, `firebase`,
     `excalidraw`). Ignore the claude.ai connector table entirely.
   - Check whether `~/.claude/skills/<name>/` exists for each skill listed.
   - Check whether `~/.claude/rules/context7.md` exists.
   - Check whether `~/.claude/plugins/marketplaces/claude-plugins-official`
     exists.

4. Produce a single report with these sections:

   a. OS & resolved paths
   b. Backup commands I should run before any apply step (exact `cp` lines)
   c. settings.json diff summary (line counts + the most material changes)
   d. keybindings.json diff summary
   e. Extensions delta: { to_install: N, already_present: M, extra_on_my_machine: K }
      — list the names under each bucket, do not install
   f. MCP servers delta (machine-scoped only): missing list + the exact
      `claude mcp add` line for each — do not run them. Add a short note
      that claude.ai connectors are intentionally excluded because they
      ride with the Anthropic account.
   g. Skills delta: missing list + how to copy them (`cp -R` from your machine
      or re-install via `find-skills`)
   h. Rules / plugin marketplaces delta
   i. Apply plan: the ordered command list I would run if I approved, including
      `./install.sh`, `npx ctx7 setup`, and any `claude mcp add` lines for
      servers ctx7 doesn't cover (Composio + local stdio). Mark whether
      Composio's `/mcp` OAuth would be needed. Do NOT include any step that
      touches claude.ai connectors.

5. Stop. Wait for me to say "apply" before doing anything in step 4i.

Hard rules:
- Never run `./install.sh`, `code --install-extension`, `claude mcp add`,
  `npx ctx7 setup`, or `/mcp` during this dry run.
- Never overwrite, delete, or rename any file under
  `~/Library/Application Support/Code/User/`,
  `~/.config/Code/User/`,
  `~/.claude/`, or `~/.claude.json`.
- Never authenticate to claude.ai connectors, Composio, Context7, or any
  third party. If an OAuth flow would be required to "verify" something,
  describe that fact in the plan instead of starting the flow.
- Never touch claude.ai connector configuration. The account-bound list
  above is off-limits — don't add, remove, re-auth, or even diagnose them.
- If you're unsure whether an action is read-only, skip it and note the
  uncertainty in the plan.
```

---

## After the dry run

Once you've reviewed the plan and want to apply:

```bash
./install.sh                       # settings, keybindings, extensions
npx ctx7 setup                     # context7 MCP + skill + rule (handles API key)
# then for the rest of the MCP servers, run the `claude mcp add` block in
# claude-code-config.md and OAuth into each connector via `/mcp` inside Claude Code
```
