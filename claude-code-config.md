# Claude Code Configuration Reference

_Captured 2026-05-19 from `~/.claude/`_

## 1. Global settings (`~/.claude/settings.json`)

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "theme": "dark",
  "skipDangerousModePermissionPrompt": true
}
```

## 2. Global instructions (`~/.claude/CLAUDE.md`)

```markdown
# Global preferences

## Git commits and PRs

- Do **not** add Claude attribution to git artifacts. Omit the `Co-Authored-By: Claude …` trailer from commit messages and omit the "🤖 Generated with [Claude Code]" footer from PR bodies. This applies to every repo unless a project-level `CLAUDE.md` overrides it.
```

## 3. MCP servers (global / user scope)

### Remote (claude.ai connectors — OAuth)

| Server | URL |
|---|---|
| claude.ai Apollo.io | `https://mcp.apollo.io/mcp` |
| claude.ai ClickUp | `https://mcp.clickup.com/mcp` |
| claude.ai Google Drive | `https://drivemcp.googleapis.com/mcp/v1` |
| claude.ai Slack | `https://mcp.slack.com/mcp` |
| claude.ai Gmail | `https://gmailmcp.googleapis.com/mcp/v1` |
| claude.ai Microsoft 365 | `https://microsoft365.mcp.claude.com/mcp` |
| claude.ai SignNow | `https://mcp-server.signnow.com/mcp` |
| claude.ai Notion | `https://mcp.notion.com/mcp` |
| claude.ai monday.com | `https://mcp.monday.com/mcp` |
| claude.ai Linear | `https://mcp.linear.app/mcp` |
| claude.ai Intercom | `https://mcp.intercom.com/mcp` |
| claude.ai HubSpot | `https://mcp.hubspot.com/anthropic` |
| claude.ai Figma | `https://mcp.figma.com/mcp` |
| claude.ai Canva | `https://mcp.canva.com/mcp` |
| claude.ai Box | `https://mcp.box.com` |
| claude.ai Atlassian | `https://mcp.atlassian.com/v1/mcp` |
| claude.ai Asana | `https://mcp.asana.com/sse` |

### Remote (HTTP)

| Server | URL |
|---|---|
| context7 | `https://mcp.context7.com/mcp` |

### Local (stdio)

| Server | Command |
|---|---|
| chrome-devtools | `npx -y chrome-devtools-mcp` |
| playwright | `npx -y @automatalabs/mcp-server-playwright` |
| terraform | `docker run -i --rm hashicorp/terraform-mcp-server` |
| firebase | `npx -y firebase-tools experimental:mcp` |
| excalidraw | `npx -y @scofieldfree/excalidraw-mcp` |

### Replication commands

```bash
# HTTP / SSE remote servers
claude mcp add --transport http context7 https://mcp.context7.com/mcp
claude mcp add --transport http "claude.ai Apollo.io"      https://mcp.apollo.io/mcp
claude mcp add --transport http "claude.ai ClickUp"        https://mcp.clickup.com/mcp
claude mcp add --transport http "claude.ai Google Drive"   https://drivemcp.googleapis.com/mcp/v1
claude mcp add --transport http "claude.ai Slack"          https://mcp.slack.com/mcp
claude mcp add --transport http "claude.ai Gmail"          https://gmailmcp.googleapis.com/mcp/v1
claude mcp add --transport http "claude.ai Microsoft 365"  https://microsoft365.mcp.claude.com/mcp
claude mcp add --transport http "claude.ai SignNow"        https://mcp-server.signnow.com/mcp
claude mcp add --transport http "claude.ai Notion"         https://mcp.notion.com/mcp
claude mcp add --transport http "claude.ai monday.com"     https://mcp.monday.com/mcp
claude mcp add --transport http "claude.ai Linear"         https://mcp.linear.app/mcp
claude mcp add --transport http "claude.ai Intercom"       https://mcp.intercom.com/mcp
claude mcp add --transport http "claude.ai HubSpot"        https://mcp.hubspot.com/anthropic
claude mcp add --transport http "claude.ai Figma"          https://mcp.figma.com/mcp
claude mcp add --transport http "claude.ai Canva"          https://mcp.canva.com/mcp
claude mcp add --transport http "claude.ai Box"            https://mcp.box.com
claude mcp add --transport http "claude.ai Atlassian"      https://mcp.atlassian.com/v1/mcp
claude mcp add --transport sse  "claude.ai Asana"          https://mcp.asana.com/sse

# Local stdio servers
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp
claude mcp add playwright      -- npx -y @automatalabs/mcp-server-playwright
claude mcp add terraform       -- docker run -i --rm hashicorp/terraform-mcp-server
claude mcp add firebase        -- npx -y firebase-tools experimental:mcp
claude mcp add excalidraw      -- npx -y @scofieldfree/excalidraw-mcp

# Then run /mcp inside Claude Code to OAuth into each remote connector.
```

## 4. Skills (`~/.claude/skills/`)

**Clerk family**
- `clerk` (router)
- `clerk-setup`
- `clerk-android`
- `clerk-astro-patterns`
- `clerk-backend-api`
- `clerk-billing`
- `clerk-chrome-extension-patterns`
- `clerk-custom-ui`
- `clerk-expo-patterns`
- `clerk-nextjs-patterns`
- `clerk-nuxt-patterns`
- `clerk-orgs`
- `clerk-react-patterns`
- `clerk-react-router-patterns`
- `clerk-swift`
- `clerk-tanstack-patterns`
- `clerk-testing`
- `clerk-vue-patterns`
- `clerk-webhooks`

**Vercel / React / Next**
- `deploy-to-vercel`
- `vercel-cli-with-tokens`
- `vercel-composition-patterns`
- `vercel-react-best-practices`
- `vercel-react-native-skills`
- `vercel-react-view-transitions`

**General dev**
- `code-structure`
- `drizzle`
- `find-skills`
- `flutter-development`
- `godot`
- `pdf-to-markdown`
- `web-design-guidelines`

> Replicate by copying `~/.claude/skills/` to the new machine, or re-install individually via the `find-skills` / `skill-creator` workflow.

## 5. Plugin marketplaces

Marketplace installed: **`claude-plugins-official`** (at `~/.claude/plugins/marketplaces/claude-plugins-official`).

Available plugins from it (not necessarily enabled — enable via `/plugin`):

```
agent-sdk-dev          claude-code-setup       claude-md-management
code-modernization     code-review             code-simplifier
commit-commands        cwc-makers              example-plugin
explanatory-output-style  feature-dev          frontend-design
hookify                learning-output-style    math-olympiad
mcp-server-dev         playground              plugin-dev
pr-review-toolkit      ralph-loop              security-guidance
session-report         skill-creator
# Language servers:
clangd-lsp  csharp-lsp  gopls-lsp  jdtls-lsp  kotlin-lsp  lua-lsp
php-lsp  pyright-lsp  ruby-lsp  rust-analyzer-lsp  swift-lsp  typescript-lsp
```

### Replication

```bash
# Inside Claude Code:
/plugin marketplace add anthropics/claude-code   # adds claude-plugins-official
/plugin install <plugin-name>                    # enable the ones you want
```
