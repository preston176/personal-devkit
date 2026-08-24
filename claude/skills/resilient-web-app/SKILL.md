---
name: resilient-web-app
description: Build web apps that survive idle/backgrounded tabs, expired sessions, and redeploys — no frozen spinners, stuck redirects, unclickable buttons, or hung actions. Use when scaffolding a new web app or SPA; when writing or reviewing Server Actions / server functions and their client callers; when wiring auth or sessions (Clerk, NextAuth/Auth.js, Supabase, custom JWT); when adding fetch/data-fetching, redirects, loading states, spinners, or error boundaries; or when adding SSE/WebSockets/real-time. Triggers on: "create a web app", "add a server action", "add login/auth", "loading state", "stuck spinner", "tab idle/backgrounded", "session expired", "redirect not working", "hung request". Apply proactively — these are defaults for the whole app, not a special mode.
---

# Resilient Web Apps

Web apps break in a specific, recurring way after a tab has been **backgrounded, idle, or open across a redeploy**: frozen loading states, stuck redirects, unclickable buttons, actions that hang until the user hits F5. It is never one bug — it's the sum of small omissions (a swallowed error, a missing `finally`, a fetch with no timeout, no session recheck on focus). This skill encodes the defaults that prevent the whole class.

Treat these as **build-time defaults**, not a review-only checklist. When you write the code the first time, write it this way.

## When this applies

- Any app with a **client that stays open across time**: dashboards, SaaS, admin panels, editors, anything behind a login.
- Strongest signal: **Server Actions / server functions** + **short-lived session tokens** (Clerk defaults to 60s tokens) + **client-side loading state**. That combination is where the confirmed failures live.
- Framework notes below target **Next.js App Router (15+) / React 19**, but every rule has a framework-agnostic principle that transfers to Remix, SvelteKit, TanStack Start, or a plain SPA.

**When NOT to bother:** fully static sites, pages with no auth and no mutations, or a page the user never leaves open. Lower stakes — don't over-engineer.

---

## The failure class in one sentence

A tab resumes from a frozen/idle/stale state and the app **keeps a promise it can never keep** — a request that will never respond, a redirect that was swallowed, a spinner tied to a promise that will never settle — with **no timeout and no escape hatch** to break the user out.

Every guardrail below either (a) makes a stuck promise impossible, or (b) gives the user a way out when one happens anyway.

---

## The guardrails

### 1. Never swallow framework control-flow errors at a call site  ⚠️ highest impact

In App Router, `redirect()` and `notFound()` **throw** (`NEXT_REDIRECT` / `NEXT_NOT_FOUND`). A Server Action that redirects **rejects its client promise** with that error, and navigation only happens if the error reaches the framework's `RedirectBoundary`. A `try/catch` that turns every rejection into a `toast.error(...)` **eats the redirect** — the page goes dead and every later action fails the same way. This is the single most common cause of "stuck redirect" + "hung action."

- **Do:** in any `catch` around a server-action call or a function that may `redirect()`/`notFound()`, call `unstable_rethrow(err)` from `next/navigation` **first**, then handle domain errors. It re-throws framework errors and passes real ones through.
- **Do:** prefer `useActionState` + `<form action={...}>` — the framework surfaces redirects for you and gives you `isPending` for free (guardrail 3).
- **Do:** centralize action calls in one `callAction()` wrapper so no call site can forget.
- **Don't:** wrap `redirect()` in `try/catch` on the server. Call it **after** the try block.
- **Principle (any framework):** distinguish *framework/control-flow* errors from *domain* errors. Only catch what you can meaningfully show the user; re-throw the rest.

### 2. Recheck the session when the tab comes back

Short-lived tokens (Clerk ~60s, refreshed every minute) **cannot refresh while the tab is frozen**. Return after minutes → token expired → the next action fails or bounces. The browser's own refresh won't have run.

- **Do:** mount one root-level component that, on `visibilitychange`→`visible` (plus `focus` and `pageshow`), and only if idle beyond a threshold (~60s), hits a **cheap session-validation endpoint**; if invalid → send to sign-in, if valid → `router.refresh()`.
- **Do:** add a trivial `GET /api/session` (or equivalent) that returns 200/401 and does no heavy work.
- **Principle:** a client that can outlive its credentials must re-verify them on resume, before the user's first click does.

### 3. Loading state must always resolve — reset in `finally`, or let the framework own it

A `setPending(true)` that resets only in the success path or only in `catch` leaves a **stuck spinner / permanently disabled button** whenever the promise doesn't take that path (including a swallowed redirect from guardrail 1).

- **Do:** prefer `useTransition` / `useActionState` — `isPending` is framework-managed and clears automatically across navigation and errors.
- **Do:** if hand-rolling, reset the flag in a `finally`, never only in `catch` or only on success.
- **Do:** if you guard against double-submit with a ref/flag, make sure a wedged call still has a recovery path (timeout in guardrail 4) — otherwise the button is dead *and* retries are dropped.
- **Principle:** for every "start busy" there must be an unconditional "stop busy."

### 4. Every request and every action call needs a timeout

A `fetch` with no `AbortSignal.timeout()` can hang forever on a socket that died while the tab was frozen. A streaming `reader.read()` with no idle timeout hangs on a stalled stream. An awaited server-action promise with no bound hangs the UI.

- **Do:** one shared `fetch` wrapper with a default timeout (e.g. `AbortSignal.timeout(30_000)`) and per-call override. Route all fetches through it.
- **Do:** for streams, add an **idle** timeout (no chunk within N seconds → abort), separate from any total cap.
- **Do:** bound server-action calls too (`Promise.race` with a timeout, or an abort) and surface a retry affordance on timeout — don't silently retry forever.
- **Principle:** no unbounded waits. Anything that can hang gets a deadline and a user-visible outcome.

### 5. Refresh stale data on focus

After backgrounding, cached RSC payloads / query caches can be stale with nothing triggering a re-fetch.

- **Do:** the `router.refresh()` in guardrail 2 covers the vanilla case.
- **Do:** if using React Query / SWR, keep `refetchOnWindowFocus` **on** (it's the default — don't disable it without a reason).
- **Principle:** resuming a tab is a "you might be looking at stale state" signal; act on it.

### 6. Survive redeploys (deployment skew)

After a redeploy, an old tab holds **stale server-action IDs**; the new server can't find them and action calls fail until a reload. Symptoms look identical to the idle-tab failure.

- **Do:** expose a build ID to the client (`generateBuildId` → `NEXT_PUBLIC_BUILD_ID`) and a cheap `GET /api/build`. On focus, compare; if it differs, show a non-blocking "Reload to update" prompt.
- **Do:** mount a global listener for `unhandledrejection`/`error` that matches the skew error family (`failed to find server action`, `older or newer deployment`, `unexpected response was received from the server`) and reloads **once**, guarded so it can't loop.
- **Principle:** the client build and server build can drift; detect the drift and recover instead of dead-ending.

### 7. Always give the user an escape hatch

No `global-error.tsx` / `error.tsx` means a thrown render is a white screen with only F5. A "Loading…" or "Redirecting…" state with no timeout can display forever.

- **Do:** add root `app/global-error.tsx` and `app/error.tsx` with a visible "Reload" / `reset()` button; add segment `error.tsx` on heavy routes.
- **Do:** put a timeout on any long-lived "Loading…"/"Redirecting…" screen that reveals a manual "Try again" → `window.location.reload()` after a few seconds.
- **Principle:** the user must never be trapped with F5 as their only option. Every stuck state needs a visible way out.

### 8. Real-time connections: prove liveness, reconnect on resume

`readyState === OPEN` is **not** proof the connection is alive — a frozen tab can hold an open-but-dead socket, and `EventSource`'s built-in reconnect can't run while frozen.

- **Do:** send a server heartbeat/ping and track `lastMessageAt` on the client; treat the connection as dead if no message arrived within ~2× the heartbeat interval, even if `OPEN`.
- **Do:** reconnect on `visibilitychange`→`visible` and `online`; drive reconnection yourself with capped backoff rather than trusting the built-in retry.
- **Do:** cap server stream duration just below the platform's idle-connection cutoff and let the client reconnect.
- **Principle:** liveness is proven by recent traffic, not by socket state.

---

## Minimum acceptance checklist

Before shipping any authenticated, mutating web surface, confirm:

- [ ] No `catch` swallows a redirect — `unstable_rethrow` (or framework equivalent) runs before domain handling (G1)
- [ ] Session is re-validated on tab return / focus (G2)
- [ ] Every loading flag resets in `finally` or is framework-managed (G3)
- [ ] Every `fetch` and action call has a timeout; streams have an idle timeout (G4)
- [ ] Stale data refreshes on focus; `refetchOnWindowFocus` not disabled (G5)
- [ ] Build-skew detection + guarded one-shot reload is mounted (G6)
- [ ] `global-error.tsx` + `error.tsx` exist; long "Loading…/Redirecting…" states have a manual reload fallback (G7)
- [ ] Real-time connections use heartbeat + `lastMessageAt` liveness and reconnect on resume (G8)

## References

- `references/patterns.md` — copy-paste-ready good/bad code for each guardrail (the `callAction` wrapper, `IdleResync`, `useServerAction`, the fetch wrapper, error boundaries, SSE liveness).
- `references/review-checklist.md` — grep-driven audit for finding these issues in an existing codebase, with the exact search commands.
