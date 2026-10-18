# Elevare Studio — Agent Team

A complete, reusable studio that produces **top-tier products and full marketing programs** — strategy, design, full-stack build, quality, launch, marketing assets, and growth. Machine-wide: available in **every** project on this computer — authored on `~/.claude/agents/` and **copied** into `~/.claude/agents/`, which is the tree Claude Code actually loads. **It is a copy, not a link: an edit on `D:` is not live until it is synced.**

Every agent follows [STANDARDS.md](STANDARDS.md); anyone touching a visual surface holds to [CRAFT.md](CRAFT.md) — the universal craft floor. **[ARCHETYPES.md](ARCHETYPES.md) sets the direction on top of that floor:** every visual job declares one of seven archetypes (product-tool · editorial commerce · immersive · local trust · content/media · conversational · internal operator console) plus **one signature moment**, so an apparel drop is benchmarked against Nike/Adidas/Aesop and a restaurant against the operators who actually convert — not everything against Linear. **[INDUSTRIES.md](INDUSTRIES.md)** carries the sector playbooks (money moment, required sections, trust proof, schema, booking/payment, compliance landmines, the #1 failure) for the verticals the studio sells into. Each agent pulls methodology from the installed skills — read `~/.claude/skills/<name>\SKILL.md` directly (authored on `~/.claude/skills`; `C:` is the copy that loads, and **a skill that exists only on `D:` is not installed**). Count the directory, never a number written in a doc.

**Start here to understand how it all runs:** [PLAYBOOK.md](PLAYBOOK.md) — the end-to-end process (intake → triage → plan → execute → gate → ship → measure → **learn**), the handoff protocol, sign-off gates, and a concrete recipe per job type. [SKILLS-MAP.md](SKILLS-MAP.md) routes every installed skill to the agents that own them. The two conductors below drive the process; specialists execute.


## Conductors
- **delivery-lead** — runs a whole product build: decompose → route to specialists → hold quality gates → track → keep you in control.
- **marketing-strategist** — runs a whole marketing program: positioning → campaign + content calendar → route to the creative/channel team → assemble → measure.

## Strategy
- **product-strategist** — brief → build plan (pages, data model, stack, milestones)
- **business-strategist** — market/competitor research, positioning, pricing, investor materials
- **brand-strategist** — verbal brand: positioning, messaging framework, tone, naming, taglines

## Design (craft ceiling — [CRAFT.md](CRAFT.md) · direction — [ARCHETYPES.md](ARCHETYPES.md))
- **design-researcher** — benchmark best-in-class → patterns to beat them
- **art-director** — creative vision + final taste gate (SHIP / FIX / REWORK)
- **ux-designer** — flows, IA, interaction, friction removal
- **ui-designer** — interface design + tokens + every state → spec
- **brand-identity-designer** — logo/wordmark, color + type systems, iconography, guidelines
- **motion-designer** — micro-interactions, transitions, scroll choreography

## Build
- **frontend-builder** — UI implementation, on-brand + accessible (static-first default)
- **design-engineer** — pixel-perfect, performant implementation (advanced CSS, animation, WebGL/Canvas)
- **backend-engineer** — APIs, serverless/edge, auth, business logic
- **database-architect** — schema, migrations, indexes, Supabase RLS
- **payments-engineer** — Stripe checkout, subscriptions, metering/credits, webhooks
- **ai-engineer** — LLM/agents/RAG/prompts/MCP, cost + latency optimization
- **devops-engineer** — CI/CD, containers, environments/secrets, monitoring, incident response (app-scale)
- **analytics-engineer** — product event instrumentation, dashboards, SQL/warehouse (distinct from marketing-analyst)
- **automation-engineer** — internal automations, pipelines, scheduled jobs/webhooks (studio ops + client deliverables)
- **brand-copywriter** — product/site copy in the client's real voice

## Marketing & Creative
- **content-engine-lead** — owns the always-on content engine as a system (pillars, batch production, cadence, scheduler wiring, editorial calendar) and conducts the content pod toward three standing goals: reliability (never runs dry), credibility (honest proof/authority), conversions (funnel-mapped). Distinct from marketing-strategist (bounded campaigns) and social-media-manager (execution/community)
- **conversion-copywriter** — ad/landing/sales/email copy that converts
- **graphic-asset-designer** — social graphics, ad creative, banners, carousels, OG images, posters
- **video-producer** — video ads, reels/shorts, promos, explainers, product demos
- **motion-ad-director** — jaw-dropping animated ADS: concept→storyboard→elite motion (kinetic type, seamless loops, product reveals, particle/SVG/WebGL FX) — the scroll-stopping advertisement as a craft object
- **ai-media-producer** — AI-generated imagery / video / voiceover / music
- **presentation-designer** — sales & marketing decks, one-pagers
- **social-media-manager** — content calendars, platform-native posts, engagement, repurposing
- **social-growth-strategist** — the "social media master": real-time hashtag science, optimal-timing windows, trend intelligence + honest trendjacking, and feature-hinting — tactics that make posts spread AND convert; feeds social-media-manager + content-engine-lead (doesn't run the calendar itself)
- **email-marketer** — newsletters, welcome/lifecycle/drip sequences, broadcasts
- **seo-specialist** — keyword/intent research, on-page + technical SEO, content briefs
- **paid-ads-specialist** — Meta/Google/TikTok/LinkedIn campaign structure, targeting, creative briefs
- **growth-marketer** — acquisition experiments, funnel/CRO, referral loops, lead gen
- **marketing-analyst** — funnel/campaign analytics, KPIs, A/B analysis, reporting

## Business & Growth (how the studio makes money)
- **offer-architect** — turn capabilities into productized offers: scope, pricing, guarantees, and the fee shape. **Elevare sells no retainer, care plan, maintenance plan, content subscription or monthly fee** — the recurring revenue IS the invoiced percentage (BP §2); hard asks are flat-price projects
- **cold-email-specialist** — cold acquisition email: prospect targeting, hyper-personalization, cold sequences, and deliverability (separate sending domain, SPF/DKIM/DMARC, warmup, tool choice) — opens the funnel; hands replies to sales-closer (drafts only)
- **sales-closer** — outreach, discovery prep, proposals/SOWs, follow-ups, objection handling (drafts only)
- **client-partner** — onboarding, progress updates, delivery/handoff, retention & referrals. **Nothing to upsell:** there is no retainer or plan (BP §2) — retention means keeping the site SELLING, because the studio is only invoiced when the client earns
- **rehearsal-partner** — adversarial role-play BEFORE the call: plays a specific difficult local-business owner, holds character through the money objections ("so you take a cut of my money forever?", the arrears + 12-month buyout, "Wix is $16 a month"), then breaks for a blunt numbered debrief and a harder rerun. **Rehearses only — drafts nothing, sends nothing** (sales-closer drafts pre-signature, client-partner post-signature). Built for voice mode on a walk: short spoken turns, one question, no markdown in the scene

## Quality gates (run before every ship)
- **code-quality-engineer** — refactor for reuse/simplicity, kill dead code (behavior-preserving)
- **simplicity-gate** — LAST gate on any code change (Fable, VETO): "is this the simplest change that does the job?"
- **test-engineer** — automated unit/integration/E2E + TDD
- **design-auditor** — visual consistency, tokens, contrast (AA), slop-check + fixes
- **security-reviewer** — secrets, XSS, headers, deps — release gate
- **qa-verifier** — drives the real UI, proves flows work, zero console errors
- **social-post-critic** — the gate on **every finished visual** before it ships: social graphics, print pieces, identity boards, exported decks, ad creative. Judges audience fit plus the mechanical defects (uneven optical sizing, clipped glyphs, orphans, off-spec ratios, type unreadable at thumbnail, effective DPI at trim size) — SHIP / FIX / REWORK
- **performance-engineer** — Core Web Vitals, latency, bundle, cost (measured)

## Ship & support
- **launch-engineer** — SEO/perf/headers/manifest + Vercel deploy (prod only on sign-off)
- **compliance-counsel** — privacy policy / ToS / cookie + GDPR/CCPA/CAN-SPAM drafts + risk flags (not legal advice)
- **docs-writer** — READMEs, specs, API docs, user guides, handoff briefs
- **codebase-navigator** — orient fast in an existing/unfamiliar repo before changing it

## Brand-specific pods (experts for one brand, operating inside the studio flow)
- **Example Brand** — a 7-agent pod for the founder's memento-mori graphic-apparel house (Next.js 16 + Supabase + Stripe + provider-agnostic POD): **example-brand-brand-guardian** (the "is this Example Brand?" taste + voice gate), **example-brand-graphic-designer** (new engravings + apparel print art + the card deck, web SVG + 300-DPI POD print), **example-brand-merchandiser** (POD catalog ops, blanks/colorways, pricing/margin), **example-brand-drop-strategist** (numbered drops, ceremony, collect-the-cards loyalty, The Order/Custodians), **example-brand-conversion-copywriter** (memento-mori PDP/drop/email/ad copy + CRO), **example-brand-growth-marketer** (paid + acquisition + Custodian recruiting), **example-brand-social-content** (always-on IG/TikTok organic + drop hype). **★ BRAND FROZEN — hibernating since 2026-09-05.** `<project-repo>`, the Vercel project and the Supabase project were all deleted; the storefront 404s. The brand docs survive in GitHub `your-github-org/example-brand` @ `master` and are read from there — **do not read from `<project-repo>`, it is gone.** No Example Brand execution work until the owner lifts the freeze (`BUSINESS-PLAN.md` §Phase 6). Freeze terms and the full restore map: [example-brand-TEAM.md](example-brand-TEAM.md), which every agent in the pod must read before starting anything. They compose under delivery-lead / marketing-strategist.

## Job-type pods (specialists for one recurring kind of job, inside the studio flow)
- **intranet portal** — crew portals that ship as a legacy intranet CMS `.aspx` pages on a ship's network (the Example Portal portal, its linked programs, the fleet template for other units). Run with [the portal playbook (not included)](the portal playbook (not included)); every pod agent reads its Lessons ledger first. **sp-portal-conductor** (runs the release: owner-rule checklist, contract, parallel lanes, ONE combined gate, small-first publish, resume log, ledger loop) · **sp2016-lab-operator** (real SP2016 VM 130 + mock: lock protocol, one scripted run, update/rollback, screenshots, cleanup) · **approval-officer (not included)** (ISSM packet: OSS currency/CVE, SBOM, CSP, markings, 508, PII/PIA, approval route) · **fleet-roster-researcher** (sub roster, crests, squadrons, contrast-mapped colorways) · **portal-guide-keeper** (CHANGELOG to guides + troubleshooting, non-author walk). Studio gates and builders are reused, not duplicated.

## Self-improvement layer (the flywheel — this is why the studio compounds)
- **retrospective** — runs LAST on any job: finds the blind spots the other agents missed and writes durable lessons back into the agent definitions / STANDARDS / CRAFT / PLAYBOOK / memory
- **agent-architect** — designs/creates/refines the studio's own agents to spec (grows the roster correctly, no bloat)
- **skill-forge** — turns a recurring pattern/lesson into a real installed skill the whole team gains
- **eval-master** — measures whether changes actually improved quality (evals/benchmarks/regressions) — turns "we improved" into a number
- **memory-curator** — consolidates/dedupes/prunes memory + docs so the ruleset stays sharp instead of bloating (the counterweight to retrospective)
- **pattern-librarian** — harvests reusable components/templates into a growing library so each build starts faster

## Typical runs (conductors orchestrate; scale down for small jobs)
- **Product:** `product-strategist → art-director → ux → ui (+brand-identity) → build (front/back/data/AI/payments, + copy) → motion → gates (code-quality, test, design, security, qa, performance) + art-director taste gate → simplicity-gate (last, Fable, VETO) → docs → launch`
- **Marketing:** `marketing-strategist → brand-strategist (message) + brand-identity-designer (look) → conversion-copywriter → creative (graphic-asset-designer / video-producer / ai-media-producer / presentation-designer) → channels (social / email / seo / paid) → marketing-analyst`

Independent steps run in parallel. Always run the gates before a real ship; **never merge to `main`, deploy to production, publish, send, or spend ad budget without explicit sign-off** — production agents draft/stage, the human approves the go-live.

## How to invoke
- Ask by name: *"delivery-lead, plan this build"*, *"marketing-strategist, run a launch campaign"*, *"video-producer, make a 9:16 reel"*, *"run security-reviewer + qa-verifier on the branch"*.
- Or via the Agent tool with `subagent_type: "<name>"`. Independent agents can run in parallel.

## Notes
- **Newly added agents register on the next session.** If a name isn't available as a `subagent_type` yet, restart the session (or, one-off, run a general-purpose agent told to read that agent's `.md` first).
- **★ Machine-wide, TWO trees — `D:` authors, `C:` loads.** Canonical files are authored on `~/.claude/agents/` and **copied** to `~/.claude/agents/`. The `C:` tree is a real directory of independent files, **not a symlink**, and it is the only one Claude Code reads. **An edit on `D:` that is not synced does not exist to any session — no error, no warning, only silence.** That is not hypothetical: `C:` sat frozen at 2026-07-01 for two months while every agent ran a July version, and 15 skills authored on `D:` were never once loadable. Sync runs automatically at every session start (`~/.claude/state/capture-state.ps1`, drift count reported in `STATE.md`); to force it:
  ```
  robocopy "~/.claude/agents" "~/.claude/agents" /E /XD ".git" "__pycache__"
  robocopy "~/.claude/skills" "~/.claude/skills" /E /XD ".git" "__pycache__"
  ```
  Never `/MIR`. Verify with `diff -rq`. To prove a skill or agent is loadable, look for its name in a session's own available list, not on disk.
- **Tuning:** edit any agent's `.md`; edit [STANDARDS.md](STANDARDS.md) / [CRAFT.md](CRAFT.md) to move the bar for the whole team at once.
