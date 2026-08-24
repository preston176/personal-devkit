# Resilient Web App — Copy-Paste Patterns

Framework-specific code for Next.js App Router (15+) / React 19. Adapt imports for other frameworks; the principles in `SKILL.md` transfer.

---

## G1 — Don't swallow framework control-flow errors

### The bug

```tsx
// ❌ Swallows the NEXT_REDIRECT that requireWorkspace()/redirect() throws.
// The action rejected with a redirect; this eats it and the page goes dead.
async function onSave() {
  setBusy(true);
  try {
    await updateProfile(form);       // if the session expired, this redirects → rejects
    toast.success("Saved");
  } catch (err) {
    toast.error(err instanceof Error ? err.message : "Failed"); // eats the redirect
  } finally {
    setBusy(false);
  }
}
```

### The fix — re-throw framework errors first

```tsx
import { unstable_rethrow } from "next/navigation";

async function onSave() {
  setBusy(true);
  try {
    await updateProfile(form);
    toast.success("Saved");
  } catch (err) {
    unstable_rethrow(err);   // ✅ re-throws NEXT_REDIRECT / NEXT_NOT_FOUND so navigation happens
    toast.error(err instanceof Error ? err.message : "Failed"); // only real domain errors reach here
  } finally {
    setBusy(false);
  }
}
```

### Server side — call `redirect()` outside try/catch

```ts
"use server";
import { redirect } from "next/navigation";

export async function createPost(data: FormData) {
  const session = await auth();
  if (!session?.user) redirect("/sign-in");  // ✅ outside any try/catch

  try {
    await db.insert(...);                     // domain work that may throw domain errors
  } catch (e) {
    return { ok: false, error: "Could not save" }; // return, don't throw, for expected failures
  }
  revalidatePath("/posts");
  redirect("/posts");                          // ✅ after the try block
}
```

### Best — a central `callAction` wrapper (no call site can forget)

```ts
// lib/callAction.ts
import { unstable_rethrow } from "next/navigation";

const SKEW = /failed to find server action|older or newer deployment|unexpected response was received from the server/i;

export async function callAction<T>(
  fn: () => Promise<T>,
  opts: { retries?: number; timeoutMs?: number } = {},
): Promise<T> {
  const retries = Math.max(1, opts.retries ?? 3);
  const timeoutMs = opts.timeoutMs ?? 20_000;
  let lastErr: unknown;

  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      return await withTimeout(fn(), timeoutMs);
    } catch (err) {
      unstable_rethrow(err);           // redirect/notFound bubble to RedirectBoundary
      lastErr = err;
      if (SKEW.test(String((err as Error)?.message ?? err))) {
        reloadOnceForSkew();           // deploy skew: reload once (see G6)
        throw err;
      }
      if (attempt < retries - 1) await sleep(500 * (attempt + 1));
    }
  }
  throw lastErr;
}

function withTimeout<T>(p: Promise<T>, ms: number): Promise<T> {
  return new Promise((resolve, reject) => {
    const t = setTimeout(() => reject(new Error(`Action timed out after ${ms}ms`)), ms);
    p.then((v) => { clearTimeout(t); resolve(v); },
           (e) => { clearTimeout(t); reject(e); });
  });
}
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));
```

### Even better — let the framework own redirects + pending

```tsx
"use client";
import { useActionState } from "react";
import { updateProfile } from "@/app/_actions/profile";

export function ProfileForm() {
  const [state, action, isPending] = useActionState(updateProfile, null);
  return (
    <form action={action}>
      {/* fields */}
      <button disabled={isPending}>{isPending ? "Saving…" : "Save"}</button>
      {state?.error && <p role="alert">{state.error}</p>}
    </form>
  );
}
// A redirect() inside updateProfile is surfaced by the framework — you never
// see it, never swallow it, and isPending clears automatically.
```

---

## G2 — Recheck session on tab return

```ts
// app/api/session/route.ts
import { auth } from "@clerk/nextjs/server";           // or your provider's server helper
export const dynamic = "force-dynamic";

export async function GET() {
  const { userId } = await auth();
  return Response.json({ ok: Boolean(userId) }, { status: userId ? 200 : 401 });
}
```

```tsx
// components/IdleResync.tsx — mount once in the root layout
"use client";
import { useEffect, useRef } from "react";
import { useRouter } from "next/navigation";

const IDLE_MS = 60_000;

export function IdleResync() {
  const router = useRouter();
  const hiddenAt = useRef<number | null>(null);

  useEffect(() => {
    const onHidden = () => { hiddenAt.current = Date.now(); };

    const resync = async () => {
      const idleFor = hiddenAt.current ? Date.now() - hiddenAt.current : 0;
      hiddenAt.current = null;
      if (idleFor < IDLE_MS) return;                    // short blips: skip
      try {
        const res = await fetch("/api/session", {
          cache: "no-store",
          signal: AbortSignal.timeout(10_000),
        });
        if (!res.ok) { window.location.href = "/sign-in"; return; }
        router.refresh();                               // valid → pull fresh RSC
      } catch {
        /* offline: leave the page; the next real request will surface it */
      }
    };

    const onVisibility = () => {
      if (document.visibilityState === "hidden") onHidden();
      else void resync();
    };

    document.addEventListener("visibilitychange", onVisibility);
    window.addEventListener("focus", () => void resync());
    window.addEventListener("pageshow", () => void resync());  // bfcache restore
    return () => {
      document.removeEventListener("visibilitychange", onVisibility);
    };
  }, [router]);

  return null;
}
```

---

## G3 — Loading state that always resolves

```tsx
// ✅ Framework-managed pending — clears across success, error, and navigation.
const [isPending, startTransition] = useTransition();
const onClick = () =>
  startTransition(async () => {
    try { await doThing(); }
    catch (err) { unstable_rethrow(err); toast.error("…"); }
  });

// ✅ Hand-rolled: reset in finally, never only in catch or only on success.
async function run() {
  setBusy(true);
  try { await doThing(); }
  catch (err) { unstable_rethrow(err); toast.error("…"); }
  finally { setBusy(false); }        // <- unconditional
}
```

```tsx
// ❌ The AppHeader bug: reset only in catch. Success path (which navigates
//    away or resolves) never clears it → button disabled forever.
setSwitching(true);
try { await switchWorkspace(id); router.push("/"); }
catch { setSwitching(false); }       // missing the success/finally reset
```

---

## G4 — Timeouts everywhere

```ts
// lib/fetch.ts — the only fetch the app calls directly
export async function apiFetch(input: RequestInfo | URL, init: RequestInit & { timeoutMs?: number } = {}) {
  const { timeoutMs = 30_000, signal, ...rest } = init;
  // Compose a caller-supplied signal with the timeout, if both exist.
  const timeout = AbortSignal.timeout(timeoutMs);
  const composed = signal ? AbortSignal.any([signal, timeout]) : timeout;
  return fetch(input, { ...rest, signal: composed });
}
```

```ts
// Streaming read with an IDLE timeout (fires if no chunk arrives for N seconds).
async function readWithIdleTimeout(reader: ReadableStreamDefaultReader<Uint8Array>, idleMs = 15_000) {
  while (true) {
    const idle = new Promise<never>((_, rej) =>
      setTimeout(() => rej(new Error("stream idle timeout")), idleMs));
    const { value, done } = await Promise.race([reader.read(), idle]);
    if (done) break;
    // …handle value…
  }
}
```

---

## G6 — Deploy-skew detection + guarded reload

```ts
// next.config.ts
const buildId = process.env.GIT_SHA ?? String(Date.now());
export default {
  generateBuildId: () => buildId,
  env: { NEXT_PUBLIC_BUILD_ID: buildId },
};
```

```ts
// app/api/build/route.ts
export const dynamic = "force-dynamic";
export async function GET() {
  return Response.json({ buildId: process.env.NEXT_PUBLIC_BUILD_ID });
}
```

```ts
// lib/reloadOnceForSkew.ts — reload at most once per window so it can't loop
const KEY = "skew-reload-at";
const GUARD_MS = 60_000;
export function reloadOnceForSkew() {
  try {
    const last = Number(sessionStorage.getItem(KEY));
    if (Number.isFinite(last) && Date.now() - last < GUARD_MS) return;
    sessionStorage.setItem(KEY, String(Date.now()));
  } catch { /* private mode */ }
  window.location.reload();
}
```

```tsx
// Global backstop for unwrapped action calls (mount once in root layout).
"use client";
import { useEffect } from "react";
import { reloadOnceForSkew } from "@/lib/reloadOnceForSkew";
const SKEW = /failed to find server action|older or newer deployment|unexpected response was received from the server/i;

export function SkewGuard() {
  useEffect(() => {
    const onRej = (e: PromiseRejectionEvent) => {
      const msg = String((e.reason as Error)?.message ?? e.reason ?? "");
      if (SKEW.test(msg)) { e.preventDefault(); reloadOnceForSkew(); }
    };
    window.addEventListener("unhandledrejection", onRej);
    return () => window.removeEventListener("unhandledrejection", onRej);
  }, []);
  return null;
}
// NOTE: this only fires for UNHANDLED rejections. If every call site catches
// its own errors, this never runs — which is why G1's callAction handles skew
// inline. Use both.
```

---

## G7 — Error boundaries + escape hatches

```tsx
// app/global-error.tsx  (must render <html>/<body>; catches root-layout errors)
"use client";
export default function GlobalError({ reset }: { error: Error; reset: () => void }) {
  return (
    <html><body>
      <h2>Something went wrong</h2>
      <button onClick={() => reset()}>Try again</button>
      <button onClick={() => window.location.reload()}>Reload page</button>
    </body></html>
  );
}
```

```tsx
// app/error.tsx  (per-segment; add to heavy routes too)
"use client";
export default function Error({ reset }: { error: Error; reset: () => void }) {
  return (
    <div role="alert">
      <p>This page hit an error.</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}
```

```tsx
// Timeout an indefinite "Redirecting…" / "Loading…" screen.
const [stuck, setStuck] = useState(false);
useEffect(() => {
  const t = setTimeout(() => setStuck(true), 5_000);
  return () => clearTimeout(t);
}, []);
if (stuck) return <button onClick={() => window.location.reload()}>Taking too long — reload</button>;
return <Spinner label="Redirecting…" />;
```

---

## G8 — SSE / WebSocket liveness

```tsx
// Client: track lastMessageAt; don't trust readyState === OPEN alone.
const lastMessageAt = useRef(Date.now());
const HEARTBEAT_MS = 25_000;

function isAlive(es: EventSource | null) {
  return !!es
    && es.readyState === EventSource.OPEN
    && Date.now() - lastMessageAt.current < HEARTBEAT_MS * 2;  // recent traffic, not just OPEN
}

// On every message (including heartbeats): lastMessageAt.current = Date.now();

const revive = () => { if (!isAlive(esRef.current)) connect(); };  // reconnect if stale
document.addEventListener("visibilitychange", () => {
  if (document.visibilityState === "visible") revive();
});
window.addEventListener("online", revive);
```

```ts
// Server (SSE route): heartbeat + cap duration below the platform idle cutoff.
export const maxDuration = 300;                 // just under the infra's idle-connection limit
const HEARTBEAT_MS = 25_000;
// inside the stream: setInterval(() => controller.enqueue(encoder.encode(": ping\n\n")), HEARTBEAT_MS)
```

---

## Root layout wiring (ties it together)

```tsx
// app/layout.tsx
import { IdleResync } from "@/components/IdleResync";
import { SkewGuard } from "@/components/SkewGuard";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en"><body>
      <IdleResync />   {/* G2 + G5: session recheck + refresh on resume */}
      <SkewGuard />    {/* G6: deploy-skew backstop */}
      {children}
    </body></html>
  );
}
```
