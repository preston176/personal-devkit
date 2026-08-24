# Resilient Web App — Audit Checklist (existing codebases)

Use this to find idle-tab / session / skew vulnerabilities in code that already exists. Each item pairs a grep with what a *pass* vs *fail* looks like. Run from the app root. Prefer `rg`; exclude `node_modules`, `.next`, build output.

---

## G1 — Swallowed framework errors (start here — highest impact)

```bash
# Find server-action files, then their client call sites.
rg -l "^['\"]use server['\"]" -g '*.{ts,tsx}'
# Every client call site that catches an action call:
rg -n "await \w+\(" -g '*.tsx' -A6 | rg -n "catch"
# Does the codebase EVER re-throw framework errors?
rg -n "unstable_rethrow|isRedirectError|NEXT_REDIRECT" -g '*.{ts,tsx}'
```

- **FAIL:** zero matches for `unstable_rethrow`/`isRedirectError` **and** call sites wrap action calls in `try/catch` that toast on error. Redirects are being eaten. This is the #1 finding.
- **FAIL:** `redirect()` called *inside* a `try` block on the server.
- **PASS:** call sites use `useActionState`/`<form action>`, or every catch runs `unstable_rethrow(err)` before domain handling, or all calls route through a `callAction` wrapper that does.

## G2 — Session recheck on focus

```bash
rg -n "visibilitychange|document\.hidden|addEventListener\(['\"]focus|pageshow" -g '*.{ts,tsx}'
rg -n "getToken|useSession|refreshSession" -g '*.{ts,tsx}'   # any proactive refresh?
```

- **FAIL:** no `visibilitychange`/`focus` handler at the root/layout level that re-validates the session. (Feature-local handlers for one widget don't count.)
- **PASS:** a root-mounted component rechecks session + `router.refresh()` on resume.

## G3 — Stuck loading states

```bash
rg -n "useTransition|useActionState|useFormStatus" -g '*.{ts,tsx}'   # framework-managed pending?
rg -n "set(Busy|Loading|Pending|Submitting|Saving)\(true\)" -g '*.tsx' -B2 -A12   # inspect each: is there a finally?
```

- **FAIL:** a `setX(true)` whose reset appears only in `catch`, or only on the success line, with no `finally`.
- **FAIL:** an `inFlight`/`isSubmitting` ref that blocks re-entry with no timeout/recovery path.
- **PASS:** `useTransition`/`useActionState`, or a `finally` that unconditionally resets.

## G4 — Unbounded requests

```bash
rg -n "\bfetch\(" -g '*.{ts,tsx}' | wc -l                          # total call sites
rg -n "\bfetch\(" -g '*.{ts,tsx}' -A3 | rg -n "signal|AbortSignal" # how many have a signal?
rg -n "AbortSignal\.timeout|AbortSignal\.any" -g '*.{ts,tsx}'      # any timeouts at all?
rg -n "reader\.read\(\)|getReader\(" -g '*.{ts,tsx}'               # streaming reads → need idle timeout
```

- **FAIL:** most fetches have no timeout; no shared fetch wrapper (fetches are ad-hoc across many files); `reader.read()` in a loop with no idle timeout.
- **PASS:** one `lib/fetch.ts` wrapper with a default timeout that call sites use.

## G5 — Refresh on focus / query cache

```bash
rg -n "refetchOnWindowFocus" -g '*.{ts,tsx}'
rg -n "react-query|@tanstack/react-query|\bswr\b" package.json
```

- **FAIL:** React Query/SWR present but `refetchOnWindowFocus: false` set without a documented reason.
- **PASS:** default (on), or vanilla app relies on G2's `router.refresh()`.

## G6 — Deploy skew

```bash
rg -n "generateBuildId|NEXT_PUBLIC_BUILD_ID" -g '*.{ts,js,mjs}'
rg -n "failed to find server action|older or newer deployment|unexpected response was received" -g '*.{ts,tsx}'
rg -n "unhandledrejection" -g '*.{ts,tsx}'
```

- **FAIL:** no build-ID exposure and no skew-error listener → stale tabs dead-end after every deploy.
- **PARTIAL:** a skew listener exists but only catches `unhandledrejection` while all call sites catch their own errors (listener never fires — see the note in patterns.md G6). Needs the inline `callAction` path too.
- **PASS:** build-ID check on focus **and** guarded one-shot reload wired both inline and as a global backstop.

## G7 — Error boundaries + escape hatches

```bash
find . -path ./node_modules -prune -o \( -name 'global-error.tsx' -o -name 'error.tsx' \) -print
rg -n "location\.reload|Try again|Reload" -g '*.tsx'
rg -n "Redirecting|Loading" -g '*.tsx' -A5 | rg -n "setTimeout"   # do long waits have a timeout escape?
```

- **FAIL:** no `global-error.tsx`/`error.tsx` anywhere; "Redirecting…"/"Loading…" screens with no timeout fallback.
- **PASS:** root + segment boundaries with reset/reload; indefinite waits reveal a manual reload after a few seconds.

## G8 — Real-time liveness

```bash
rg -n "EventSource|new WebSocket|event-stream|readyState" -g '*.{ts,tsx}'
rg -n "heartbeat|ping|lastMessage|lastMessageAt" -g '*.{ts,tsx}'
```

- **FAIL:** `readyState === OPEN` used as the sole liveness check; no heartbeat; no reconnect on `visibilitychange`/`online`.
- **PASS:** heartbeat + `lastMessageAt` staleness check; self-driven reconnect on resume; server stream capped below the infra idle cutoff.

---

## Reporting template

For each guardrail: **PASS / PARTIAL / FAIL**, with `file:line` evidence. Rank findings by user impact — G1 and G3 produce the most visible "dead page" symptoms; G6 spikes right after deploys. Do not propose fixes in the audit pass unless asked; diagnose first, then apply `patterns.md`.
