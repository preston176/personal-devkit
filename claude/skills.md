# Skills reference

Skills are reusable instruction packs that Claude Code (and other agent runtimes that read the same format) load on demand. Each one lives under `~/.claude/skills/<name>/SKILL.md` with frontmatter that tells the agent **when** to fire it. You don't invoke them by name in normal use — the agent picks them up automatically based on what you're working on. The list below is the set I have installed; treat it as a tour of what's possible, not a menu to memorize.

If you want to add one I don't have, run `find-skills` inside Claude Code and ask for what you need — the marketplace search lives behind that skill.

---

## Authentication & user management — Clerk family

The most-used family. One router skill (`clerk`) dispatches into framework-specific patterns so the agent only loads what's relevant to the file you're editing.

| Skill | What it does |
|---|---|
| `clerk` | Router. Picks the right sub-skill based on whether you're in Next.js, React, Vue, Astro, Expo, etc. Start here whenever you say "add auth." |
| `clerk-setup` | Walks the official quickstart for any project: install package, wrap with `<ClerkProvider>`, add middleware, drop in sign-in. |
| `clerk-nextjs-patterns` | Middleware, Server Actions, route handlers, App Router caching — Next-specific patterns that don't transfer to other frameworks. |
| `clerk-react-patterns` | Vite / CRA SPAs: `ClerkProvider`, `useAuth` / `useUser` / `useClerk`, React Router protected routes, custom sign-in forms. |
| `clerk-react-router-patterns` | React Router v7: `rootAuthLoader`, `getAuth` in loaders, `clerkMiddleware`, SSR user data. |
| `clerk-vue-patterns` | Vue 3 composables (`useAuth`, `useUser`, etc.), Vue Router guards, Pinia store integration. |
| `clerk-nuxt-patterns` | Nuxt 3 with `@clerk/nuxt`: middleware, composables, server API routes, SSR. |
| `clerk-astro-patterns` | Astro middleware, SSR pages, island components, API routes, static vs SSR rendering. |
| `clerk-tanstack-patterns` | TanStack Start: `createServerFn`, `beforeLoad` guards, loaders, Vinxi server. |
| `clerk-expo` | Expo / React Native: `SecureStore` token cache, OAuth deep linking, Expo Router protected routes. |
| `clerk-swift` | Native iOS via `ClerkKit` / `ClerkKitUI`. Prebuilt `AuthView` or custom flows. Not for React Native. |
| `clerk-android` | Native Android via `clerk-android` + Jetpack Compose. Prebuilt `AuthView` / `UserButton` or API-driven flows. Not for React Native. |
| `clerk-chrome-extension-patterns` | Chrome extensions: popup / sidepanel setup, `syncHost` for OAuth via web app, `createClerkClient` for service workers, stable CRX IDs. |
| `clerk-custom-ui` | Custom sign-in/sign-up flows with the headless hooks; theming, colors, fonts, CSS overrides. |
| `clerk-orgs` | B2B multi-tenant: org switching, role-based access, verified domains, enterprise SSO. |
| `clerk-billing` | Subscriptions via Clerk Billing: `PricingTable`, checkout drawer, seat-limit plans, `has()` for feature gating, billing webhooks. |
| `clerk-webhooks` | `verifyWebhook` patterns. Handle user / session / org / billing / payment events for DB sync, notifications, integrations. |
| `clerk-backend-api` | REST API explorer for Clerk Backend. Browse tags, inspect schemas, execute authenticated requests — list users, manage orgs, anything the API supports. |
| `clerk-testing` | E2E tests with Playwright or Cypress against Clerk auth flows. |

**When to install only a subset:** if you only build Next.js apps, you only need `clerk` + `clerk-setup` + `clerk-nextjs-patterns` + whichever of `clerk-orgs` / `clerk-billing` / `clerk-webhooks` you actually use.

---

## Vercel, React, Next.js performance

| Skill | What it does |
|---|---|
| `deploy-to-vercel` | Deploys an app to Vercel and hands you back a link. Fires on phrases like "deploy my app," "push this live," "create a preview deployment." |
| `vercel-cli-with-tokens` | Same, but token-based instead of interactive login. Use in CI or when you don't want a browser to pop. |
| `vercel-react-best-practices` | Vercel Engineering's React + Next perf guidelines. Loads when writing / reviewing / refactoring React or Next code. |
| `vercel-composition-patterns` | Compound components, render props, context providers, React 19 API changes. Loads when you're designing a reusable component API. |
| `vercel-react-view-transitions` | React's View Transition API: `<ViewTransition>`, `addTransitionType`, CSS view transition pseudo-elements. Page transitions, shared element animations, list reorder, directional nav. |
| `vercel-react-native-skills` | React Native + Expo: list perf, animations, native modules. |

---

## Code intelligence & quality

| Skill | What it does |
|---|---|
| `fallow` | Static + runtime code-health analyzer for JS/TS. Reports quality, PR risk, unused files/exports/deps, duplication, circular deps, complexity hotspots, architecture boundary violations, feature flags, security candidates. 118 framework plugins, zero config, sub-second static analysis. Optional runtime mode merges production execution data. |
| `code-structure` | Fires when multiple workflows duplicate the same operational logic, or when deciding what belongs in actions vs shared services. Refactoring-focused. |
| `simplify` | Reviews changed code for reuse, quality, efficiency. Fixes issues it finds. |
| `review` | Reviews a pull request. |
| `security-review` | Security review of pending changes on the current branch. |
| `resilient-web-app` | Build-time defaults for web apps that survive backgrounded/idle tabs, expired sessions, and redeploys — no frozen spinners, stuck redirects, or hung actions. Fires when scaffolding a new web app/SPA, writing Server Actions, wiring auth/sessions, adding fetch/loading states, or adding SSE/WebSockets. Applied proactively, not just on review. |

---

## Documentation & research

| Skill | What it does |
|---|---|
| `context7-mcp` | Routes library / framework / SDK / API questions to the Context7 MCP server for current docs instead of relying on training data. Auto-installed by `npx ctx7 setup`. Companion rule at `~/.claude/rules/context7.md` makes this mandatory for any library question. |
| `pdf-to-markdown` | Converts whole PDFs to clean Markdown so the agent can load the full document into context. Use when grep / page-by-page would miss something. |
| `claude-api` | Build / debug / optimize Claude API + Anthropic SDK apps. Handles prompt caching, model migrations between Claude versions, replacements for retired models. Fires on `anthropic` / `@anthropic-ai/sdk` imports or when adding tool use / batching / files / citations / memory. |

---

## Writing

| Skill | What it does |
|---|---|
| `unslop` | Edits text to remove AI-writing tells (em dashes, hedging, filler) and add human voice. Marked "must always apply" — fires on any generated prose, not just on request. |

---

## Database

| Skill | What it does |
|---|---|
| `drizzle` | Drizzle ORM schema and migrations. Fires when editing files under `src/database/schemas/*` or defining tables / migrations. |

---

## Mobile & game development

| Skill | What it does |
|---|---|
| `flutter-development` | Cross-platform Flutter / Dart. Widgets, Provider / BLoC, navigation, API integration, Material. |
| `godot` | Godot Engine projects. `.gd` / `.tscn` / `.tres` formats, signal-driven and resource-based patterns, scene/resource debugging, CLI workflows. Provides the `godot` command for run / validate / import / export. |

### Expo / React Native — `expo/skills`

The official Expo skill family. Framework skills are open source; the `eas-*` skills drive the paid EAS cloud services.

| Skill | What it does |
|---|---|
| `expo-router` | File-based navigation: routes, groups, dynamic routes, `Link` with previews, folder organization. |
| `expo-project-structure` | Folder layout for a new Expo app — where each file should live when scaffolding with Expo Router. |
| `expo-ui` | Native UI via `@expo/ui`: real SwiftUI on iOS and Jetpack Compose on Android, rendered from React. |
| `expo-native-ui` | Native-feeling screens: Apple HIG styling, semantic colors, native controls, SF Symbols, animations. |
| `expo-dom` | Expo DOM components — run web code in a webview on native, as-is on web. Incremental web→native migration. |
| `expo-web-to-native` | Port an existing web React app (e.g. Next.js) into a native iOS/Android app. |
| `expo-data-fetching` | Any network request / API call: `fetch`, React Query, SWR, error handling, caching. |
| `expo-tailwind-setup` | Tailwind CSS v4 in Expo via react-native-css + NativeWind v5 for universal styling. |
| `expo-dev-client` | Build and distribute dev clients locally or via TestFlight for internal testing. |
| `expo-module` | Write Expo native modules/views with the Expo Modules API (Swift, Kotlin, TypeScript). |
| `expo-migrate-module` | Migrate an Apple/Swift native module from Expo Modules API 1.0 DSL to the 2.0 macro API. |
| `expo-brownfield` | Embed Expo / React Native into an existing native iOS or Android app. |
| `expo-app-clip` | Add an iOS App Clip target: AASA, `apple-app-site-association`, smart app banners. |
| `expo-upgrade` | Upgrade Expo SDK versions and fix dependency issues. |
| `expo-examples` | The `expo/examples` repo (~70 `with-*` integrations: Stripe, Clerk, Supabase, OpenAI, maps, SQLite…). |
| `expo-skill-eval` | Evaluate Expo skills end-to-end — trigger accuracy, code quality, simulator/emulator screenshots. |
| `expo-skill-feedback` | Submit feedback on an Expo skill (or Expo itself); toggle the opt-in anonymous usage telemetry. |
| `eas-workflows` | Write and understand EAS workflow YAML (CI/CD for Expo projects). |
| `eas-hosting` | Deploy Expo websites and Router API routes to EAS Hosting: web export, `eas deploy`, PR preview URLs. |
| `eas-update-insights` | Health of published EAS Updates: crash rates, install/launch counts, unique users, payload size. |
| `eas-observe` | EAS Observe: add `expo-observe` (AppMetricsRoot/ObserveRoot HOC, `markInteractive`) and read metrics. |
| `eas-simulator` | Run and control your app on a remote iOS/Android simulator hosted on EAS cloud. |
| `eas-app-stores` | Build and submit to the App Store, Google Play, and TestFlight; configure `eas.json`. |

---

## UI & design

| Skill | What it does |
|---|---|
| `shadcn` | Manages shadcn/ui components: add, search, fix, debug, style, compose. Triggers on `components.json` projects, `shadcn init`, or any preset code. |
| `web-design-guidelines` | Reviews UI code for accessibility, UX, and Web Interface Guidelines compliance. Fires on "review my UI," "check accessibility," "audit design." |
| `screen-demo` | Recording / capturing UI for demos. |

---

## Agent infrastructure & meta

These are the skills that operate on Claude Code itself rather than on your codebase.

| Skill | What it does |
|---|---|
| `find-skills` | Discovery. Fires when you ask "how do I do X" / "is there a skill for X" / "find a skill that…" Searches available skill marketplaces and installs the one you pick. |
| `create-task` | Scaffolds a new Harbor eval task — instruction writing, environment setup, verifier design (pytest / Reward Kit / custom), solution scripting. Use when building benchmarks or evals. |
| `init` | Initialize a new `CLAUDE.md` with codebase docs. Run once per project to give Claude Code persistent project context. |
| `update-config` | Edits `~/.claude/settings.json` (or project-level `settings.local.json`). Use for permissions, env vars, hooks, automated behaviors ("from now on when X…" — those need hooks, not memory). |
| `keybindings-help` | Customize keyboard shortcuts in `~/.claude/keybindings.json` — rebind, add chord bindings, change submit key. |
| `fewer-permission-prompts` | Scans your transcripts for common read-only Bash / MCP calls, generates a prioritized allowlist for project `.claude/settings.json`. Reduces permission noise. |
| `loop` | Run a prompt / slash command on a recurring interval (`/loop 5m /foo`). Omit the interval to let the model self-pace. For polling, status checks, repeated tasks. |
| `schedule` | Create / update / list / run scheduled remote agents on a cron schedule. Also handles one-time runs ("at 3pm, do X"). |

---

## My own skills

Skills I maintain and use across machines. Installed by cloning the source repo and symlinking into `~/.claude/skills/` so edits round-trip via `git`.

| Skill | What it does |
|---|---|
| `nextjs-structure` | Audits / refactors a Next.js codebase toward the monorepo + App Router + tRPC + feature-modular patterns used by Cal.com, Rallly, Dub, Formbricks, Inbox Zero, and other production OSS projects. Fires when asked how to structure a Next.js app or when invoking `/nextjs-structure`. Source: [github.com/preston176/nextjs-structure](https://github.com/preston176/nextjs-structure). |

---

## Plugins (enabled)

Plugins bundle a set of skills + agents + slash commands under one install. Enabled via `/plugin install <name>` from inside Claude Code (see [`config.md`](./config.md) for the marketplace).

| Plugin | What it adds |
|---|---|
| `superpowers` | A ~14-skill process pack that changes how the agent works, not just what it knows. Includes `brainstorming` (mandatory before creative work), `systematic-debugging` (mandatory for any bug/test failure), `test-driven-development`, `writing-plans` + `executing-plans` + `subagent-driven-development`, `verification-before-completion`, `requesting-code-review` + `receiving-code-review`, `dispatching-parallel-agents`, `using-git-worktrees`, `writing-skills`, `finishing-a-development-branch`, `using-superpowers` (the entry-point rule). If you install one plugin, install this one. |
| `pr-review-toolkit` | Adds the `/review-pr` slash command plus a fleet of subagents: `code-reviewer`, `silent-failure-hunter`, `type-design-analyzer`, `comment-analyzer`, `pr-test-analyzer`, `code-simplifier`. Use before opening or merging a PR. |

---

## How to add or remove skills on a new machine

This repo gives you two install paths:

```bash
# All at once (recommended)
./scripts/install-skills.sh

# Or selectively, by source
npx skills add clerk/skills@clerk-nextjs-patterns -g -y   # marketplace
cp -R claude/skills/godot ~/.claude/skills/                # standalone (in-repo)
```

Find new skills via the `find-skills` skill inside Claude Code, or browse
[`skills.sh`](https://skills.sh/). Remove one with `rm -rf ~/.claude/skills/<name>`.

### Why two paths?

| Source | Where it lives | How it replicates |
|---|---|---|
| Marketplace (Clerk, Vercel, shadcn, fallow, Harbor, unslop) | symlink under `~/.claude/skills/` pointing into `~/.agents/skills/` | `npx skills add <owner/repo@skill> -g -y` |
| Standalone (drizzle, pdf-to-markdown, code-structure, flutter-development, godot, resilient-web-app) | real folder under `~/.claude/skills/` | copied wholesale into `claude/skills/` in this repo |
| Own (nextjs-structure) | symlink under `~/.claude/skills/` pointing into `~/Code/personal/<repo>` | `git clone` the source repo, then `ln -s` into `~/.claude/skills/` |
| Auto-installed (context7-mcp) | real folder under `~/.claude/skills/` | comes for free with `npx ctx7 setup` |
| Heavy (screen-demo, 454 MB) | real folder under `~/.agents/skills/` | install on demand; too big to bundle |
| Plugin-bundled (superpowers, pr-review-toolkit) | under `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/skills/` | `/plugin install <name>` from inside Claude Code |

---

## How skills, rules, and plugins relate

- **Skills** (`~/.claude/skills/<name>/SKILL.md`) — loaded on demand based on the task. The agent decides when to fire one. Think: domain-specific instruction packs.
- **Rules** (`~/.claude/rules/<name>.md`) — always-on instructions. The Context7 rule, for example, *forces* the agent to look up library docs before answering. Use rules for guarantees, skills for capabilities.
- **Plugins** (`~/.claude/plugins/`) — bundle of skills + agents + commands + hooks. Installed from a marketplace via `/plugin install <name>`. See [`config.md`](./config.md) for the marketplace I use.

Skills are the unit you'll touch most often.
