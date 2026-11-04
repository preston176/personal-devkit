# Claude Code Configuration Reference

_Captured 2026-08-24 from `~/.claude/`. Skills, plugins and settings refreshed 2026-09-26; skills again 2026-10-17 and 2026-11-04._

## 1. Global settings (`~/.claude/settings.json`)

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "model": "opus[1m]",
  "enabledPlugins": {
    "pr-review-toolkit@claude-plugins-official": true,
    "superpowers@claude-plugins-official": false,
    "mcpmarket-me@mcpmarket-me": true
  },
  "extraKnownMarketplaces": {
    "mcpmarket-me": {
      "source": {
        "source": "directory",
        "path": "/Users/preston/.claude/plugins/mcpmarket-me"
      }
    }
  },
  "effortLevel": "xhigh",
  "skipDangerousModePermissionPrompt": true,
  "theme": "dark",
  "modelSettings": {
    "claude-opus-5-5": {
      "effortLevel": "high"
    }
  }
}
```

Note: `superpowers` is installed but currently **disabled** (`false`); `pr-review-toolkit` and `mcpmarket-me` are active. See section 5.

`extraKnownMarketplaces` points at a **local directory**, so it will not resolve on a fresh machine until that plugin is re-added (section 5). The absolute path under `/Users/preston` is machine-specific.

## 2. Global instructions (`~/.claude/CLAUDE.md`)

```markdown
# Global preferences

## Writing style

- Avoid em dashes (—) in prose and generated text. Rephrase with commas, parentheses, colons, or separate sentences instead.

## Git commits and PRs

- Do **not** add Claude attribution to git artifacts. Omit the `Co-Authored-By: Claude …` trailer from commit messages and omit the "🤖 Generated with [Claude Code]" footer from PR bodies. This applies to every repo unless a project-level `CLAUDE.md` overrides it.
```

### Global rules (`~/.claude/rules/`)

- `context7.md` — installed by `npx ctx7 setup`. Forces Context7 MCP lookups for library/framework/SDK/CLI questions before answering. See `~/.claude/rules/context7.md` (also auto-installed when running `ctx7` again).

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
| claude.ai Composio | `https://connect.composio.dev/mcp` |
| claude.ai Intuit QuickBooks | `https://ai-inc.quickbooks.intuit.com/v1/mcp` |

### Remote (HTTP)

| Server | URL | Notes |
|---|---|---|
| context7 | `https://mcp.context7.com/mcp` | configured with API key via `npx ctx7 setup` (stored in `~/.claude.json`) |
| composio | `https://connect.composio.dev/mcp` | OAuth via `/mcp`; exposes tool search + remote workbench / bash |

### Local (stdio)

| Server | Command |
|---|---|
| chrome-devtools | `npx -y chrome-devtools-mcp` |
| playwright | `npx -y @automatalabs/mcp-server-playwright` |
| terraform | `docker run -i --rm hashicorp/terraform-mcp-server` |
| firebase | `npx -y firebase-tools experimental:mcp` |
| excalidraw | `npx -y @scofieldfree/excalidraw-mcp` |
| rea | `npx -y rea-agents@6.8.0 mcp` (needs Node 22.23.4+, 24.22.1+ or 26.12.1+; Ghidra / JADX engines are separate installs) |

### Replication commands

```bash
# Context7 (preferred: handles API key + installs companion skill/rule)
npx ctx7 setup

# HTTP / SSE remote servers (skip context7 if you used ctx7 above)
claude mcp add --transport http context7 https://mcp.context7.com/mcp
claude mcp add --transport http composio https://connect.composio.dev/mcp
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
claude mcp add --transport http "claude.ai Composio"       https://connect.composio.dev/mcp
claude mcp add --transport http "claude.ai Intuit QuickBooks" https://ai-inc.quickbooks.intuit.com/v1/mcp

# Local stdio servers
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp
claude mcp add playwright      -- npx -y @automatalabs/mcp-server-playwright
claude mcp add terraform       -- docker run -i --rm hashicorp/terraform-mcp-server
claude mcp add firebase        -- npx -y firebase-tools experimental:mcp
claude mcp add excalidraw      -- npx -y @scofieldfree/excalidraw-mcp
# rea: let its own setup write the entry (backs up ~/.claude.json, keeps the skills.sh skill)
npx -y rea-agents@latest setup --client claude_code --skill=false

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
- `clerk-expo`
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

**Expo / EAS** _(`expo/skills`)_
- `expo-router`
- `expo-project-structure`
- `expo-ui`
- `expo-native-ui`
- `expo-dom`
- `expo-web-to-native`
- `expo-data-fetching`
- `expo-tailwind-setup`
- `expo-dev-client`
- `expo-module`
- `expo-migrate-module`
- `expo-brownfield`
- `expo-app-clip`
- `expo-upgrade`
- `expo-examples`
- `expo-skill-eval`
- `expo-skill-feedback`
- `eas-workflows`
- `eas-hosting`
- `eas-update-insights`
- `eas-observe`
- `eas-simulator`
- `eas-app-stores`

**General dev**
- `code-structure` _(source: `michaelshimeles/skills`)_
- `context7-mcp` _(installed by `npx ctx7 setup`)_
- `create-task`
- `drizzle`
- `fallow`
- `find-skills`
- `flutter-development`
- `godot`
- `grilling` + `grill-me` _(marketplace: `mattpocock/skills`)_
- `pdf-to-markdown`
- `resilient-web-app`
- `reverse-engineer-anything` _(marketplace: `morluto/rea`)_
- `reverse-engineering` _(skillfish: `plurigrid/asi`)_
- `screen-demo` _(separate repo — see install command below)_
- `shadcn`
- `tdd` _(marketplace: `mattpocock/skills`)_
- `unslop` _(marketplace: `pstack/skills`)_
- `web-design-guidelines`

**Design & motion**
- `impeccable` _(own CLI: `npx impeccable install --global --providers claude`; also writes hooks into `settings.local.json`)_
- `landing-page-design` _(standalone, vendored in `claude/skills/`; source: `elayadesign/ai-design-skills`)_
- `animate` _(marketplace: `emilkowalski/skills`)_
- `animate-expo` _(marketplace: `emilkowalski/skills`)_
- `emil-design-eng` _(marketplace: `emilkowalski/skills`)_

**Creative & media** _(`higgsfield-ai/skills`)_

These are routers over the `higgsfield` CLI, which is a separate global install
(`npm i -g @higgsfield/cli`, then `higgsfield login`). Without it, the skills load but cannot run.

- `higgsfield-generate` _(entry point: images, video, 3D, audio)_
- `higgsfield-brandkit`
- `higgsfield-marketplace-cards`
- `higgsfield-product-photoshoot`
- `higgsfield-soul-id`
- `higgsfield-video-explainer`
- `higgsfield-websites`
- `higgsfield-youtube-thumbnail`

**Account-synced** _(`~/.claude/skills/synced/`)_

A bucket of skills synced from the claude.ai account rather than installed on this
machine. They ride with the Anthropic login, the same way the connectors in section 3
do, so there is nothing to replicate here and nothing to bundle. Do not copy this folder.

> Replicate by copying `~/.claude/skills/` to the new machine, or re-install individually via the `find-skills` / `skill-creator` workflow. The `context7-mcp` skill is auto-installed when you run `npx ctx7 setup`.
>
> **screen-demo** lives at its own repo (454 MB — Remotion + Steel deps, too large to bundle here):
> ```bash
> git clone https://github.com/preston176/screen-demo-skill.git ~/.agents/skills/screen-demo
> bash ~/.agents/skills/screen-demo/install.sh
> # then: cp ~/.agents/skills/screen-demo/.env.example ~/.agents/skills/screen-demo/.env
> # and add your STEEL_API_KEY
> ```

## 5. Plugin marketplaces

Marketplaces installed:

| Marketplace | Source | Location |
|---|---|---|
| `claude-plugins-official` | github `anthropics/claude-plugins-official` | `~/.claude/plugins/marketplaces/claude-plugins-official` |
| `mcpmarket-me` | local directory | `~/.claude/plugins/mcpmarket-me` |

### Enabled on this machine

| Plugin | Version | Status | What it adds |
|---|---|---|---|
| `pr-review-toolkit` | — | enabled | `/review-pr` command + subagents: `code-reviewer`, `silent-failure-hunter`, `type-design-analyzer`, `comment-analyzer`, `pr-test-analyzer`, `code-simplifier`. |
| `mcpmarket-me` | 0.1.0 | enabled | Bundles the `javascript` skill (core JS conventions and idioms) plus `SessionStart` / `PostToolUse` hooks that sync skills on startup and log skill invocations. Installed from a **local directory** marketplace, not GitHub. |
| `superpowers` | 6.4.1 | installed, **disabled** | ~14 process skills: `brainstorming`, `systematic-debugging`, `test-driven-development`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `dispatching-parallel-agents`, `using-git-worktrees`, `writing-skills`, `finishing-a-development-branch`, `using-superpowers`. Turned off via `enabledPlugins` in `settings.json` (see section 1). See [`skills.md` → Plugins](./skills.md#plugins-enabled). |

### Available in the marketplace (not necessarily enabled)

```
agent-sdk-dev          claude-code-setup       claude-md-management
code-modernization     code-review             code-simplifier
commit-commands        cwc-makers              example-plugin
explanatory-output-style  feature-dev          frontend-design
hookify                learning-output-style    math-olympiad
mcp-server-dev         mcp-tunnels              playground
plugin-dev             pr-review-toolkit        project-artifact
ralph-loop             receipts                 security-guidance
session-report         skill-creator
# Language servers:
clangd-lsp  csharp-lsp  gopls-lsp  jdtls-lsp  kotlin-lsp  lua-lsp
php-lsp  pyright-lsp  ruby-lsp  rust-analyzer-lsp  swift-lsp  typescript-lsp
```

### Replication

```bash
# Inside Claude Code:
/plugin marketplace add anthropics/claude-code   # adds claude-plugins-official
/plugin install superpowers                      # process skills bundle
/plugin install pr-review-toolkit                # /review-pr + review subagents

# mcpmarket-me: the local directory above will not exist on a fresh machine,
# so re-add it from its upstream repo instead.
/plugin marketplace add knoxgraeme/mcpmarket-plugin
/plugin install mcpmarket-me

# ...or /plugin install <any other name> from the list above.
```

## 6. Third-party model launchers

_Added 2026-11-03._ Two zsh functions in `~/.zshrc` that start Claude Code on a non-Anthropic model. Everything they set is scoped to that one command, so plain `claude` keeps using the claude.ai subscription. Inside each session the `/model` picker shows only that provider's model, and every alias (opus, sonnet, haiku, fable) maps to it so background tasks and subagents never request a Claude model.

API keys are **not** in this repo. Each launcher reads its key from a `chmod 600` file and refuses to start if the file is missing or empty (with an empty token Claude Code would fall back to the claude.ai login and send it to the third party).

| Command | Provider | Model | Key file | How it connects |
|---|---|---|---|---|
| `claude-morph` | Morph | `morph-dsv41flash-abliterated` | `~/.config/morph/api_key` | Morph's Anthropic-compatible endpoint, direct |
| `claude-venice` | Venice | `deepseek-v4-1-flash-1017-uncensored` | `~/.config/venice/api_key` | Local LiteLLM proxy on `127.0.0.1:4141` (Venice is OpenAI-format only) |

`morph-dsv41flash-abliterated` needs Morph account approval (`403` without it); the request form is at `GET/POST https://www.morphllm.com/api/privileged-access`.

### Replication

```bash
# Keys (paste your own; never commit them)
mkdir -p ~/.config/morph ~/.config/venice
(umask 077; printf '%s' 'sk-...' > ~/.config/morph/api_key)
(umask 077; printf '%s' 'VENICE_INFERENCE_KEY_...' > ~/.config/venice/api_key)

# LiteLLM proxy for claude-venice
uv tool install 'litellm[proxy]'

# Optional: Morph CLI. Its macOS build ships with a broken ad-hoc signature,
# so macOS kills it on launch until it is re-signed locally.
curl -fsSL https://www.morphllm.com/install.sh | bash   # fails its own --version check
codesign --force --sign - ~/.local/bin/morph && morph --version
morph token set --api-key "$(cat ~/.config/morph/api_key)"
```

`~/.config/venice/litellm.yaml`:

```yaml
model_list:
  - model_name: deepseek-v4-1-flash-1017-uncensored
    litellm_params:
      model: openai/deepseek-v4-1-flash-1017-uncensored
      api_base: https://api.venice.ai/api/v1
      api_key: os.environ/VENICE_API_KEY
litellm_settings:
  drop_params: true  # Claude Code sends Anthropic-only params Venice would reject
general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
```

Append to `~/.zshrc`:

```zsh
# Claude Code on Morph. Env is scoped to this one command; plain `claude` is untouched.
# Key guard matters: with an empty token Claude Code would fall back to your claude.ai login and send it to Morph.
claude-morph() {
  local m="morph-dsv41flash-abliterated" key="$(cat ~/.config/morph/api_key 2>/dev/null)"
  : ${key:?missing ~/.config/morph/api_key}
  ANTHROPIC_BASE_URL="https://api.morphllm.com" \
  ANTHROPIC_AUTH_TOKEN="$key" \
  ANTHROPIC_MODEL="$m" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$m" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$m" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="$m" \
  ANTHROPIC_DEFAULT_FABLE_MODEL="$m" \
  claude --settings "{\"modelPicker\":{\"replaceBuiltInOptions\":true,\"options\":[{\"model\":\"$m\",\"label\":\"DeepSeek V4.1 Flash Uncensored (Morph)\"}]}}" "$@"
}

# Claude Code on Venice via a local LiteLLM proxy (Venice has no Anthropic endpoint).
# Same gating as claude-morph: env is scoped to this command, proxy dies when claude exits.
# shortcut: fixed port 4141, so one claude-venice session at a time; pick a free port if you need more.
claude-venice() {
  local m="deepseek-v4-1-flash-1017-uncensored" port=4141 key="$(cat ~/.config/venice/api_key 2>/dev/null)"
  : ${key:?missing ~/.config/venice/api_key}
  local mk="sk-$(openssl rand -hex 16)"
  VENICE_API_KEY="$key" LITELLM_MASTER_KEY="$mk" \
    litellm --config ~/.config/venice/litellm.yaml --host 127.0.0.1 --port $port >~/.config/venice/proxy.log 2>&1 &!
  local pid=$!
  trap "kill $pid 2>/dev/null" EXIT
  until curl -sf "http://127.0.0.1:$port/health/liveliness" >/dev/null; do
    kill -0 $pid 2>/dev/null || { echo "proxy failed, see ~/.config/venice/proxy.log" >&2; return 1; }
    sleep 0.5
  done
  ANTHROPIC_BASE_URL="http://127.0.0.1:$port" \
  ANTHROPIC_AUTH_TOKEN="$mk" \
  ANTHROPIC_MODEL="$m" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$m" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$m" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="$m" \
  ANTHROPIC_DEFAULT_FABLE_MODEL="$m" \
  claude --settings "{\"modelPicker\":{\"replaceBuiltInOptions\":true,\"options\":[{\"model\":\"$m\",\"label\":\"DeepSeek V4.1 Flash 1017 Uncensored (Venice)\"}]}}" "$@"
}
```
