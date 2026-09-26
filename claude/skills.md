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
| `code-structure` | Fires when multiple workflows duplicate the same operational logic, or when deciding what belongs in actions vs shared services. Refactoring-focused. Source: [github.com/michaelshimeles/skills](https://github.com/michaelshimeles/skills/tree/main/code-structure). |
| `simplify` | Reviews changed code for reuse, quality, efficiency. Fixes issues it finds. |
| `review` | Reviews a pull request. |
| `security-review` | Security review of pending changes on the current branch. |
| `resilient-web-app` | Build-time defaults for web apps that survive backgrounded/idle tabs, expired sessions, and redeploys — no frozen spinners, stuck redirects, or hung actions. Fires when scaffolding a new web app/SPA, writing Server Actions, wiring auth/sessions, adding fetch/loading states, or adding SSE/WebSockets. Applied proactively, not just on review. |
| `tdd` | Test-first loop: red → green → refactor, with the reference material that makes the tests worth keeping — what a good test is, seams (test at public boundaries, never internals), where mocks belong, and the anti-patterns. Fires when you ask to build a feature or fix a bug test-first, say "red-green-refactor," or want integration tests. Reads `CONTEXT.md` and local ADRs first so test names match the project's domain language. |

---

## Planning & decision-making

| Skill | What it does |
|---|---|
| `grilling` | Interviews you relentlessly about a plan, decision, or idea until you both land on a shared understanding. Maps the problem as a design tree and works it in numbered rounds, asking every question whose prerequisites are already settled, with its own recommended answer attached to each so you can wave through the ones you don't care about. Fires on any "grill" trigger phrase. |
| `grill-me` | The `/grill-me` entrypoint. Marked `disable-model-invocation`, so it never fires on its own; it only runs when you invoke it by name, and it hands straight off to `grilling`. Install both: on its own it has nothing to call. |

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
| `landing-page-design` | A full landing page system: intake questions, page structure, conversion copy, SEO, plus a strict visual layer (typography, spacing, corner radius, backgrounds, hero layout, icons, motion). Fires on any landing page, marketing site, or page section work, even when you never say "design". Opinionated by intent: when its rules conflict with a framework default, it wins; when they conflict with your explicit prompt, you win. Standalone folder, vendored in this repo. |
| `impeccable` | Design and frontend quality: UX review, visual hierarchy, information architecture, accessibility, responsive behavior, theming, typography, spacing, color, motion, UX copy, error and empty states. Bundles an anti-pattern detector (`npx impeccable detect`) and installs PostToolUse + Stop hooks that check UI files as you edit. Run `/impeccable init` once per project to give it design context. Installed by its own CLI, not the skills marketplace. |
| `shadcn` | Manages shadcn/ui components: add, search, fix, debug, style, compose. Triggers on `components.json` projects, `shadcn init`, or any preset code. |
| `web-design-guidelines` | Reviews UI code for accessibility, UX, and Web Interface Guidelines compliance. Fires on "review my UI," "check accessibility," "audit design." |
| `screen-demo` | Recording / capturing UI for demos. |

### Motion and design engineering (`emilkowalski/skills`)

| Skill | What it does |
|---|---|
| `animate` | Builds a web animation by working through the decisions in the order that actually determines whether it feels right: should this animate at all, what purpose does it serve, which properties, which curve and duration, how it interrupts, how it exits. Writes the implementation, not just advice. |
| `animate-expo` | The same discipline for React Native and Expo, where the constraints differ: which thread the animation runs on, spring versus timing, how a gesture hands off, how it degrades on a slow device. Uses Reanimated, Gesture Handler, Expo Router, and expo-haptics. Reach for this over `animate` in any RN app. |
| `emil-design-eng` | The taste layer behind the other two. Emil Kowalski's philosophy on UI polish, component design, and the invisible details that separate software that works from software that feels good. Read it when you want judgement, not a recipe. |

---

## Creative & media generation (`higgsfield-ai/skills`)

Eight routers over one CLI. They do not generate anything themselves: each one
assembles a prompt and shells out to `higgsfield`, which is a **separate global
install** and needs an account:

```bash
npm i -g @higgsfield/cli
higgsfield login
```

Without that, the skills still load and still fire, and then fail at the first
Bash call. Install the CLI first or skip the whole group.

| Skill | What it does |
|---|---|
| `higgsfield-generate` | The entry point, and the one to reach for by default. Generic image, video, 3D asset, and audio generation, plus image-to-video, reframing, ad creative via Marketing Studio, and virality prediction. |
| `higgsfield-brandkit` | Complete visual brand systems: palettes, SVG logo marks, typography, mockups, packaging, signage, posters, decks, and editable PPTX/PDF brandbooks. Preserves supplied official assets and regenerates only what depends on a change. |
| `higgsfield-product-photoshoot` | Brand-quality product photography: studio shots, lifestyle scenes, hero banners, carousels, virtual try-on, ad creative packs. |
| `higgsfield-marketplace-cards` | Marketplace listing images specifically: compliant main image, secondary shots, A+ content modules. The compliance rules live server-side. |
| `higgsfield-youtube-thumbnail` | High click-through YouTube thumbnails and vertical covers. Builds a truthful information-gap concept and preserves up to three referenced identities. |
| `higgsfield-video-explainer` | Narrated explainer videos assembled from ordered 10-second blocks: one narrator, one style key, per-block audio and video, then server-side assembly. Faceless and mascot modes, optional burned subtitles. |
| `higgsfield-soul-id` | Trains a Soul Character, a personalized model on a real face, so generated images and video stay identity-faithful. One-time training returns a `reference_id` you then pass to `higgsfield-generate`. |
| `higgsfield-websites` | Builds and deploys full-stack sites, apps, and games through the Higgsfield CLI (React 19 + TanStack Start on a Cloudflare Worker). Also owns game art: spritesheets, tileable textures, 3D character animation, music and SFX. |

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

## Plugins (enabled)

Plugins bundle a set of skills + agents + slash commands under one install. Enabled via `/plugin install <name>` from inside Claude Code (see [`config.md`](./config.md) for the marketplace).

| Plugin | What it adds |
|---|---|
| `superpowers` | A ~14-skill process pack that changes how the agent works, not just what it knows. Includes `brainstorming` (mandatory before creative work), `systematic-debugging` (mandatory for any bug/test failure), `test-driven-development`, `writing-plans` + `executing-plans` + `subagent-driven-development`, `verification-before-completion`, `requesting-code-review` + `receiving-code-review`, `dispatching-parallel-agents`, `using-git-worktrees`, `writing-skills`, `finishing-a-development-branch`, `using-superpowers` (the entry-point rule). If you install one plugin, install this one. |
| `pr-review-toolkit` | Adds the `/review-pr` slash command plus a fleet of subagents: `code-reviewer`, `silent-failure-hunter`, `type-design-analyzer`, `comment-analyzer`, `pr-test-analyzer`, `code-simplifier`. Use before opening or merging a PR. |
| `mcpmarket-me` | Bundles the `javascript` skill (core JS conventions, idioms, and modern practices, with references on async, functions, modules, objects and arrays, and JSDoc) plus hooks: a `SessionStart` hook that syncs skills on startup, and `PostToolUse` hooks that log skill invocations. Installed from a local directory marketplace at `~/.claude/plugins/mcpmarket-me`, so it needs re-adding from its upstream repo on a new machine (see [`config.md`](./config.md#5-plugin-marketplaces)). |

---

## How to add or remove skills on a new machine

This repo gives you two install paths:

```bash
# All at once (recommended)
./scripts/install-skills.sh

# Or selectively, by source
npx skills add clerk/skills@clerk-nextjs-patterns -g -y   # marketplace
cp -R claude/skills/landing-page-design ~/.claude/skills/   # standalone (in-repo)
```

Find new skills via the `find-skills` skill inside Claude Code, or browse
[`skills.sh`](https://skills.sh/). Remove one with `rm -rf ~/.claude/skills/<name>`.

### Why two paths?

| Source | Where it lives | How it replicates |
|---|---|---|
| Marketplace (Clerk, Vercel, Expo, shadcn, fallow, Harbor, unslop, grilling, tdd, Higgsfield, emilkowalski) | symlink under `~/.claude/skills/` pointing into `~/.agents/skills/` | `npx skills add <owner/repo@skill> -g -y` |
| Standalone (drizzle, pdf-to-markdown, code-structure, flutter-development, godot, resilient-web-app, landing-page-design) | real folder under `~/.claude/skills/` | copied wholesale into `claude/skills/` in this repo. Upstream sources, where the skill came from someone else's repo, are noted in `scripts/install-skills.sh` |
| Auto-installed (context7-mcp) | real folder under `~/.claude/skills/` | comes for free with `npx ctx7 setup` |
| Own installer (impeccable) | real folder under `~/.claude/skills/`, plus hooks in `~/.claude/settings.local.json` | `npx impeccable install --global --providers claude --yes` |
| Heavy (screen-demo, 454 MB) | real folder under `~/.agents/skills/` | install on demand; too big to bundle |
| CLI-backed (the 8 `higgsfield-*` routers) | symlink under `~/.claude/skills/`, but useless without the CLI | `npx skills add` for the skill, then `npm i -g @higgsfield/cli && higgsfield login` |
| Plugin-bundled (superpowers, pr-review-toolkit, mcpmarket-me) | under `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/skills/` | `/plugin install <name>` from inside Claude Code |
| Account-synced (the `synced/` bucket) | `~/.claude/skills/synced/<uuid>/` | nothing to do. These come down with the claude.ai login, not from this machine. Do not copy or bundle them. |

---

## How skills, rules, and plugins relate

- **Skills** (`~/.claude/skills/<name>/SKILL.md`) — loaded on demand based on the task. The agent decides when to fire one. Think: domain-specific instruction packs.
- **Rules** (`~/.claude/rules/<name>.md`) — always-on instructions. The Context7 rule, for example, *forces* the agent to look up library docs before answering. Use rules for guarantees, skills for capabilities.
- **Plugins** (`~/.claude/plugins/`) — bundle of skills + agents + commands + hooks. Installed from a marketplace via `/plugin install <name>`. See [`config.md`](./config.md) for the marketplace I use.

Skills are the unit you'll touch most often.
