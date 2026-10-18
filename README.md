# Studio Kit

A ready-made team of Claude Code agents, operating docs and skills for building apps,
PWAs and websites to a high bar. Secret-free; installs in one command.

**Start here:** [README-START-HERE.md](README-START-HERE.md). The method itself:
[BUILD-GUIDE.md](BUILD-GUIDE.md).

| What | Where it installs |
|---|---|
| `agents/` (specialist agents + PLAYBOOK, STANDARDS, CRAFT, ARCHETYPES, INDUSTRIES, SKILLS-MAP, ROLE-PROMPTS, SHARED-RULES) | `~/.claude/agents/` |
| `BUILD-GUIDE.md` | `~/.claude/agents/BUILD-GUIDE.md` |
| `skills/` | `~/.claude/skills/` |
| `CLAUDE-SNIPPET.md` | a marked section in `~/.claude/CLAUDE.md` (replaced on re-run, never duplicated) |
| `secrets/21st.enc` | optional: an encrypted 21st.dev key (PBKDF2-SHA256 600k + AES-256-CBC + HMAC-SHA256). Useless without the passphrase, which is never in this repo. Decrypted in memory only and registered with `claude mcp add`. |

Install:
- Windows: `irm https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.ps1 | iex`
- macOS / Linux: `curl -fsSL https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.sh | bash`

Safe to re-run. Anything you already have that differs is backed up first
(`<file>.bak-<date>` for agents, `~/.claude/skills-backup-<date>/` for skills).

Some lessons inside the agents reference other agents, skills or files that are not part of
this kit (internal ones); the agents treat those as optional.

Built by Elevare Studio.
