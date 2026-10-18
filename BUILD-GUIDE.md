# How we build apps and PWAs (the studio method)

This is the exact order the studio runs for every app. Claude: read this whole file
before planning, then follow `~/.claude/agents/PLAYBOOK.md` for the detail of each step.
Human: you can just say "act as delivery-lead, read PLAYBOOK.md and BUILD-GUIDE.md,
I'm building <app>" and Claude runs it.

---

## Part 1. The app flow, step by step

1. **Challenge the brief.** Before any code, restate the app in one sentence, name where the
   requirement came from (your own words beat a forwarded doc), challenge at least one thing,
   and ask the ONE question whose answer changes what gets built. A wrong premise passes
   every gate and is still the wrong app.
2. **Plan with `product-strategist` + `ux-designer`.** Scope, the list of screens/routes,
   the data model, the user flows (sign up, the core loop, the empty state, the error state),
   and milestones. Small first version that is TRUE, not one that only demos.
3. **Pick the archetype and set direction with `art-director`.** Read
   `~/.claude/agents/ARCHETYPES.md` and name which kind of product this is (product tool,
   editorial commerce, local trust, content, conversational, internal console...). The
   art-director writes the direction against the bar in `CRAFT.md` (sit next to
   Linear / Stripe / Vercel, not next to a template). `design-researcher` pulls real
   references for that archetype.
4. **Design in Claude Design** (claude.ai design artifacts). Give it the direction doc,
   the screen list and the tokens (Part 3). Iterate there until the key screens look right
   on a phone AND on desktop. `ui-designer` turns the result into a spec: every screen,
   every state (empty, loading, error, full), spacing and type.
5. **The stack** (our default; change it only for a reason you can say out loud):
   - **Next.js (App Router) on Vercel.** Preview deploy per branch, production on merge.
   - **Supabase**: Postgres + Auth + Storage. **RLS ON for every table**, written by
     `database-architect` before the backend touches it. No table ships without a policy,
     and every policy is tested as role `anon` and as a second user (they must see nothing
     of the first user's rows).
   - **Sign-in**: email one-time CODE (6 digits, `signInWithOtp` then `verifyOtp`) as the
     main path, plus **Sign in with Google** and **Sign in with Apple** (Apple is required
     on iOS if you offer Google). Set custom SMTP in Supabase (e.g. Resend) on day one:
     the built-in mailer only reaches your own team addresses. Why a code and not a magic
     link: see Part 2, step 8.
6. **Build** with `frontend-builder` (screens, components) and `backend-engineer`
   (API routes, server actions, auth, integrations). `design-engineer` for the hard visual
   pieces. Commit early: step 0 of any build is `git init` and a first commit.
7. **Gates, in this order, every release:**
   1. `code-quality-engineer` (clean, no dead code)
   2. `test-engineer` (unit + e2e for the core flow)
   3. `security-reviewer` (auth, RLS, secrets, input, uploads)
   4. `design-auditor` (tokens, contrast, a11y, AI-slop)
   5. `art-director` (taste: does it beat the best in its class?)
   6. `qa-verifier` (drives the real UI on a phone width, a tablet width and desktop, in
      light and dark, signed in and signed out; reports evidence, not "looks good")
   7. `performance-engineer` (Core Web Vitals, bundle size)
   8. `simplicity-gate` LAST (is this the simplest change that does the job? It can reject.)
8. **Deploy.** `launch-engineer` checks SEO/manifest/headers, then the Vercel production
   deploy. **Claude never deploys to production, publishes, sends email or spends money
   without asking you first.** After deploy, verify on the live URL, not the preview.
9. **Close with `retrospective`.** It writes what went wrong back into the agents so the
   next app goes faster.

---

## Part 2. The PWA recipe (how our installed apps update on every deploy)

The goal: the app installs to the home screen, opens fast, works offline with a branded
page, and **picks up every deploy on its own** (installed PWAs are kept suspended for days,
so without this people run last week's code).

1. **Icons from the real logo** (never a hand-drawn stand-in): `icon-192.png`,
   `icon-512.png`, `icon-512-maskable.png` (logo inside the middle 80% safe zone, solid
   background), `apple-touch-icon.png` (180x180, no transparency).
2. **Manifest** (`src/app/manifest.ts`). `id`, `start_url` and `scope` are FROZEN once
   anyone installs: iOS never re-reads them. So point `start_url` at `/app`, a route that
   only redirects; change the redirect later, never the manifest.

   ```ts
   import type { MetadataRoute } from "next";
   export default function manifest(): MetadataRoute.Manifest {
     return {
       id: "/app", start_url: "/app", scope: "/",   // FROZEN, never change
       name: "Your App", short_name: "YourApp",
       display: "standalone", orientation: "portrait",
       background_color: "#0e0c0a", theme_color: "#0e0c0a", // = your app background, no white flash
       icons: [
         { src: "/icon-192.png", sizes: "192x192", type: "image/png", purpose: "any" },
         { src: "/icon-512.png", sizes: "512x512", type: "image/png", purpose: "any" },
         { src: "/icon-512-maskable.png", sizes: "512x512", type: "image/png", purpose: "maskable" },
         { src: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
       ],
     };
   }
   ```
3. **A build id per deploy.** In `next.config.mjs`:
   ```js
   env: { NEXT_PUBLIC_BUILD_ID: process.env.VERCEL_DEPLOYMENT_ID ?? process.env.VERCEL_GIT_COMMIT_SHA ?? "dev" },
   async headers() { return [{ source: "/sw.js", headers: [
     { key: "Cache-Control", value: "no-cache, no-store, must-revalidate" },
     { key: "Service-Worker-Allowed", value: "/" } ] }]; },
   ```
   and `src/app/api/version/route.ts`:
   ```ts
   export const dynamic = "force-dynamic";
   export function GET() {
     return Response.json({ build: process.env.NEXT_PUBLIC_BUILD_ID ?? "dev" },
       { headers: { "Cache-Control": "no-store" } });
   }
   ```
4. **Serve the worker stamped with that id**, so every deploy is a byte-different worker
   with its own cache name. Keep the source in `src/sw/worker.js` with a `__BUILD_ID__`
   placeholder, and serve it from `src/app/sw.js/route.ts`:
   ```ts
   import { readFile } from "node:fs/promises"; import path from "node:path";
   export const dynamic = "force-static";
   const BUILD_ID = process.env.NEXT_PUBLIC_BUILD_ID ?? "dev";
   export async function GET() {
     const src = await readFile(path.join(process.cwd(), "src", "sw", "worker.js"), "utf8");
     if (!src.includes("__BUILD_ID__")) throw new Error("worker lost its __BUILD_ID__ placeholder");
     return new Response(src.replaceAll("__BUILD_ID__", BUILD_ID.replace(/[^A-Za-z0-9_-]/g, "")), {
       headers: { "Content-Type": "application/javascript; charset=utf-8",
                  "Cache-Control": "no-cache, no-store, must-revalidate", "Service-Worker-Allowed": "/" } });
   }
   ```
5. **The worker** (`src/sw/worker.js`): network-first for HTML, cache-first for hashed
   `/_next/static/*`, versioned cache, old caches deleted on activate, and private paths
   never cached.
   ```js
   const CACHE = "app-__BUILD_ID__";
   const OFFLINE_URL = "/offline.html";
   const PRIVATE = ["/api", "/account", "/auth", "/admin", "/checkout"]; // never cached on a device
   const isPrivate = (u) => PRIVATE.some((p) => u.pathname === p || u.pathname.startsWith(p + "/"));
   const cacheable = (u, r) => r && r.ok && !r.redirected && r.type === "basic" && !isPrivate(u)
     && !/no-store|private/i.test(r.headers.get("cache-control") || "");

   self.addEventListener("install", (e) => e.waitUntil(
     caches.open(CACHE).then((c) => Promise.allSettled([OFFLINE_URL, "/icon-192.png"].map((u) => c.add(u))))
       // first install: take over at once. An UPDATE waits for SKIP_WAITING from the page.
       .then(() => (self.registration.active ? undefined : self.skipWaiting()))));
   self.addEventListener("message", (e) => { if (e.data?.type === "SKIP_WAITING") self.skipWaiting(); });
   self.addEventListener("activate", (e) => e.waitUntil(
     caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
       .then(() => self.clients.claim())));

   self.addEventListener("fetch", (e) => {
     const req = e.request; if (req.method !== "GET") return;
     const url = new URL(req.url); if (url.origin !== location.origin || isPrivate(url)) return;
     if (req.mode === "navigate") {           // HTML: network first, then cache, then offline page
       e.respondWith(fetch(req).then((r) => { if (cacheable(url, r)) caches.open(CACHE).then((c) => c.put(req, r.clone())); return r; })
         .catch(async () => (await caches.match(req)) || caches.match(OFFLINE_URL)));
       return;
     }
     if (url.pathname.startsWith("/_next/static/")) { // hashed files never go stale: cache first
       e.respondWith(caches.match(req).then((hit) => hit || fetch(req).then((r) => {
         if (cacheable(url, r)) caches.open(CACHE).then((c) => c.put(req, r.clone())); return r; })));
     }
   });
   ```
6. **Register it and keep installed apps current** (`PWARegister.tsx`, a client component
   in the root layout). Check `/api/version` on load, when the app comes back to the
   foreground after 30s+, and every 10 minutes while visible. If the live build differs:
   tell the waiting worker `SKIP_WAITING`, reload on `controllerchange`. If the user is
   mid-checkout or has typed into a form, show the **"Updated, tap to refresh"** toast
   instead and reload only on tap.
   ```tsx
   "use client";
   import { useEffect, useState } from "react";
   const BUILD = process.env.NEXT_PUBLIC_BUILD_ID ?? "dev";
   export function PWARegister() {
     const [toast, setToast] = useState(false);
     useEffect(() => {
       if (!("serviceWorker" in navigator) || process.env.NODE_ENV !== "production") return;
       let reg: ServiceWorkerRegistration | undefined; let hiddenAt = 0;
       const held = () => location.pathname.startsWith("/checkout") || !!document.querySelector("[data-hold-updates]");
       const apply = () => { const w = reg?.waiting; if (!w) return location.reload();
         navigator.serviceWorker.addEventListener("controllerchange", () => location.reload(), { once: true });
         w.postMessage({ type: "SKIP_WAITING" }); setTimeout(() => location.reload(), 3000); };
       const check = async () => {
         await reg?.update().catch(() => {});
         const live = await fetch("/api/version", { cache: "no-store" }).then((r) => r.json()).then((j) => j.build).catch(() => null);
         if (live && live !== BUILD) held() ? setToast(true) : apply();
       };
       navigator.serviceWorker.register("/sw.js", { updateViaCache: "none" }).then((r) => { reg = r; check(); });
       const vis = () => { if (document.hidden) { hiddenAt = Date.now(); return; }
         if (hiddenAt && Date.now() - hiddenAt > 30_000) check(); hiddenAt = 0; };
       document.addEventListener("visibilitychange", vis);
       const t = setInterval(() => { if (!document.hidden) check(); }, 10 * 60_000);
       (window as any).__applyUpdate = apply;
       return () => { document.removeEventListener("visibilitychange", vis); clearInterval(t); };
     }, []);
     return toast ? (
       <button className="update-toast" onClick={() => (window as any).__applyUpdate?.()}>
         Updated, tap to refresh
       </button>
     ) : null;
   }
   ```
7. **Offline page** `public/offline.html`: one self-contained file (inline CSS, your logo,
   your colors, "You're offline, this will reload when you're back" and a Retry button).
   It is precached in the worker's install step.
8. **Install prompt.** Android Chrome fires `beforeinstallprompt`: save the event, show your
   own small card from the visitor's second page view, call `event.prompt()` on tap. iPhone
   Safari has no install API: show the "Share, then Add to Home Screen" steps instead. Never
   show it inside the installed app (`matchMedia('(display-mode: standalone)')` or
   `navigator.standalone`), never on desktop, never on checkout; a dismiss hides it 60 days.
9. **iOS notch and home bar.** In `layout.tsx`:
   ```ts
   export const viewport = { width: "device-width", initialScale: 1, viewportFit: "cover", themeColor: "#0e0c0a" };
   export const metadata = { appleWebApp: { capable: true, statusBarStyle: "black-translucent", title: "YourApp" } };
   ```
   and pad with the safe-area insets (they are only real numbers with `viewport-fit=cover`):
   ```css
   .pt-safe { padding-top: env(safe-area-inset-top, 0px); }
   .pb-safe { padding-bottom: env(safe-area-inset-bottom, 0px); }
   .tabbar  { padding-bottom: calc(0.5rem + env(safe-area-inset-bottom, 0px)); }
   ```
10. **Why the email CODE beats a magic link in an installed iOS app.** An installed iOS PWA
    has its own storage, separate from Safari. A magic link opens in Safari (or the mail
    app's browser), so the user ends up signed in THERE and still signed out inside the
    app. A 6-digit code is typed inside the app, so the session lands where the user is.
    Keep the link in the same email as a fallback for desktop if you like, but the code is
    the primary path.

Test it like a user: install on a real iPhone and an Android phone, deploy a visible change,
background the app for a minute, reopen, and confirm it updated. Then go offline and confirm
the offline page.

---

## Part 3. "All the styles": the design system approach

1. **Tokens first, components second.** Every color, radius, shadow, space and font size is a
   CSS variable on `:root`. Components only ever use tokens, never raw hex values.
2. **Light/dark with three states** (system, light, dark): default follows the OS, and a
   saved choice overrides it.
   ```css
   :root { --bg:#ffffff; --fg:#111111; --muted:#5f6368; --surface:#f6f6f4; --accent:#c2410c; --line:#e5e5e2; }
   @media (prefers-color-scheme: dark) {
     :root:not([data-theme="light"]) { --bg:#0e0c0a; --fg:#f2efe9; --muted:#a19d95; --surface:#1a1714; --accent:#f97316; --line:#2a2622; }
   }
   :root[data-theme="dark"] { --bg:#0e0c0a; --fg:#f2efe9; --muted:#a19d95; --surface:#1a1714; --accent:#f97316; --line:#2a2622; }
   body { background: var(--bg); color: var(--fg); }
   ```
   A tiny inline script in `<head>` sets `data-theme` from `localStorage` before first paint
   (no flash); the toggle cycles system / light / dark.
3. **Type pairing.** One display face for headlines + one text face for everything else (or
   one family in two weights). A type scale of 5 to 7 sizes, never more. Body 16px minimum on
   phones, line length 60 to 75 characters for reading text.
4. **Spacing.** A 4px base scale (4, 8, 12, 16, 24, 32, 48, 64). Tap targets at least 44x44.
   Consistent section rhythm; nothing touches the screen edge on a phone (16px gutter).
5. **The craft bar** (`CRAFT.md`, `STANDARDS.md`): real content and real photos, every state
   designed (empty, loading, error, full), contrast AA or better, one accent color used with
   intent. **Anti AI-slop:** no purple-to-blue gradients by default, no generic hero with three
   icon cards, no emoji as icons, no lorem ipsum, no fake testimonials or numbers, no
   "AI-sounding" copy. `design-auditor` checks all of it.
6. **21st.dev components, the right way:** search 21st.dev for the component (via the MCP,
   Part 4), get it, then **rebuild it on YOUR tokens**: swap every hard-coded color, radius,
   shadow and font for your variables, delete what you do not need, and make it pass your
   light AND dark themes. Never paste stock styling into the app; a pasted component is how a
   product starts looking like every other product.

---

## Part 4. Installing the 21st.dev MCP (component search inside Claude Code)

Official setup page: https://21st.dev/mcp (their CLI: `npx @21st-dev/cli@latest init --client claude`).
The server is `https://21st.dev/api/mcp` over HTTP with an `x-api-key` header.

**If you were given the encrypted key:** the kit installer does this for you. The
passphrase comes by TEXT, separately (it is never in the email or the repo).

**To use your own key** (get one at https://21st.dev/mcp after signing in), run the same
command on Windows (PowerShell) or Mac/Linux (Terminal), with your key pasted in:

```bash
claude mcp add --transport http --scope user 21st https://21st.dev/api/mcp --header "x-api-key: YOUR_21ST_KEY"
claude mcp list
```

`claude mcp list` should show `21st: https://21st.dev/api/mcp (HTTP) - Connected`. The key
is stored in your user Claude config (`~/.claude.json`); never commit it to a repo.
Restart Claude Code after adding it.
