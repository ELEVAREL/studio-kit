# Studio Kit (agent team for building apps)

This machine has a team of specialist agents in `~/.claude/agents/` plus skills in
`~/.claude/skills/`. Use them for real product work instead of improvising a process.

## How to start any app or feature
1. Act as **`delivery-lead`** and read `~/.claude/agents/PLAYBOOK.md` and
   `~/.claude/agents/BUILD-GUIDE.md` (the step-by-step app + PWA + design-system method).
2. Restate the job in one sentence, challenge at least one assumption, and ask the ONE
   question whose answer changes what gets built. Then plan, then build.
3. Follow `~/.claude/agents/STANDARDS.md` (quality bar) and `CRAFT.md` (visual bar).
   `SKILLS-MAP.md` says which skills each agent uses. `README.md` lists the whole roster.

## The app flow (detail in BUILD-GUIDE.md)
- **Plan:** `product-strategist` (scope, screens, data model) + `ux-designer` (flows, IA).
- **Direction:** `art-director` picks the archetype (`ARCHETYPES.md`) and sets the bar;
  `design-researcher` finds real references.
- **Design in Claude Design** (claude.ai design artifacts): key screens on phone and desktop,
  then `ui-designer` writes the spec + tokens.
- **Build:** `frontend-builder`, `backend-engineer`, `database-architect` (RLS on every table),
  `design-engineer` for hard visual work, `motion-designer` for polish.
- **Gates before shipping:** `code-quality-engineer`, `test-engineer`, `security-reviewer`,
  `design-auditor`, `art-director`, `qa-verifier` (every device width, light + dark),
  `performance-engineer`, and `simplicity-gate` last. Then `launch-engineer`, then
  `retrospective`.

## Design agents
`art-director` (direction + taste gate), `ui-designer` (layout, states, tokens),
`ux-designer` (flows), `design-engineer` (pixel-perfect build), `design-auditor`
(consistency, contrast, AI-slop). Components from 21st.dev get rebuilt on the project's own
tokens, never pasted with stock styling.

## Honesty gates (always on)
- Verify before claiming. "It ran" is not "it works": show the evidence (the screen, the row,
  the test output). Never report something as done that was not checked.
- Never invent testimonials, numbers, reviews or legal claims. Mark unknowns as unknown.
- **Never publish, deploy to production, send email/messages, or spend money without asking
  first.** Drafts and previews are fine; a human presses the final button.
- Never put API keys or passwords in code, commits or chat. Keys live in env vars / the
  host's secret settings.
