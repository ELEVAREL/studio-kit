# Start here

Copy everything in the box below and paste it into Claude Code. Your Claude does the rest.

```text
Please set up the Studio Kit agent team on this computer for me. Do every step yourself and tell me what happened:

1. Work out my OS.
2. Ask me for the passphrase I was texted for the 21st.dev key (if I say I don't have one, skip the key and still do everything else). Don't repeat the passphrase back to me or write it to any file.
3. Run the installer with the passphrase in the STUDIOKIT_PASSPHRASE environment variable for that one command only:
   - Windows (PowerShell): $env:STUDIOKIT_PASSPHRASE='<passphrase>'; irm https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.ps1 | iex; Remove-Item Env:STUDIOKIT_PASSPHRASE
   - Mac or Linux (bash): curl -fsSL https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.sh | STUDIOKIT_PASSPHRASE='<passphrase>' bash
   It installs agents and docs to ~/.claude/agents, skills to ~/.claude/skills, adds a Studio Kit section to ~/.claude/CLAUDE.md, backs up anything of mine it would replace, and registers the 21st.dev MCP. If it says WRONG PASSPHRASE, ask me to re-check the text and run it again (it is safe to re-run).
4. Verify: run `claude mcp list` and confirm a line starting with "21st:", and count the .md files in ~/.claude/agents and the folders in ~/.claude/skills. Tell me the numbers.
5. Finish by telling me: "Restart Claude Code, then say: act as delivery-lead and read PLAYBOOK.md and BUILD-GUIDE.md, I'm building <your app>".
```

## The same thing in 5 plain steps

1. Have Claude Code installed and signed in to a Claude Pro or Max plan. That sign-in powers
   the agents; no API keys are needed for them.
2. Paste the box above into Claude Code.
3. When it asks, type the passphrase you were texted (only needed for the 21st.dev component
   search; you can skip it).
4. Close and reopen Claude Code.
5. Say: `act as delivery-lead and read PLAYBOOK.md and BUILD-GUIDE.md, I'm building <your app>`.

Doing it by hand instead:
- Windows (PowerShell): `irm https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.ps1 | iex`
- Mac / Linux: `curl -fsSL https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.sh | bash`

The team prepares and checks everything, but it always asks before it publishes, deploys,
sends anything or spends money.
