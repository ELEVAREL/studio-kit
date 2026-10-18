#!/usr/bin/env bash
# Studio Kit - agent team installer for Claude Code (macOS / Linux)
# ------------------------------------------------------------------
# One command:
#   curl -fsSL https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.sh | bash
# Or from a local copy of this repo:
#   bash ./install.sh
#
# Installs agents + operating docs into ~/.claude/agents, skills into ~/.claude/skills,
# and adds a "Studio Kit" section to ~/.claude/CLAUDE.md. Needs no API keys.
# Nothing you already have is overwritten: a file that differs is backed up first.
#
# Optional: the 21st.dev component MCP. If you were given a passphrase:
#   curl -fsSL .../install.sh | STUDIOKIT_PASSPHRASE='xxxx-xxxx-...' bash
# or run it in a terminal and type it when asked. Wrong passphrase = nothing changes.
#
# Env overrides (for testing): STUDIOKIT_HOME (target home dir), STUDIOKIT_SKIP_21ST=1
set -euo pipefail

TARBALL='https://codeload.github.com/ELEVAREL/studio-kit/tar.gz/refs/heads/main'
BEGIN='<!-- studio-kit:begin -->'
END='<!-- studio-kit:end -->'

c() { printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
say() { c 36 "$1"; }

echo
c 36 '=============================================='
c 1  '  Studio Kit  ->  Claude Code agent installer'
c 36 '=============================================='

HOME_DIR="${STUDIOKIT_HOME:-$HOME}"
CLAUDE="$HOME_DIR/.claude"
AGENTS_DST="$CLAUDE/agents"
SKILLS_DST="$CLAUDE/skills"
mkdir -p "$AGENTS_DST" "$SKILLS_DST"
c 90 "Target: $CLAUDE"

# --- source: local clone, or download the repo tarball ---
TMP=''
HERE=''
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; fi
if [ -n "$HERE" ] && [ -d "$HERE/agents" ] && [ -d "$HERE/skills" ]; then
  ROOT="$HERE"; say "Installing from local copy: $ROOT"
else
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/studio-kit-XXXXXX")"
  say 'Downloading the kit from GitHub...'
  curl -fsSL "$TARBALL" | tar -xz -C "$TMP"
  ROOT="$TMP/studio-kit-main"
fi
cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; return 0; }
trap cleanup EXIT

STAMP="$(date +%Y%m%d-%H%M%S)"
NEW=0; SAME=0; BAK=0

# --- agents + docs: per file; a differing file is renamed to <name>.bak-<stamp> ---
say 'Installing agents + operating docs...'
install_file() {  # src dst
  if [ -e "$2" ]; then
    if cmp -s "$1" "$2"; then SAME=$((SAME+1)); return; fi
    mv "$2" "$2.bak-$STAMP"; BAK=$((BAK+1)); c 33 "  backed up your $(basename "$2") -> $(basename "$2").bak-$STAMP"
  else NEW=$((NEW+1)); fi
  cp "$1" "$2"
}
for f in "$ROOT"/agents/*; do [ -f "$f" ] && install_file "$f" "$AGENTS_DST/$(basename "$f")"; done
[ -f "$ROOT/BUILD-GUIDE.md" ] && install_file "$ROOT/BUILD-GUIDE.md" "$AGENTS_DST/BUILD-GUIDE.md"

# --- skills: per folder. A differing folder you already have is MOVED to
#     ~/.claude/skills-backup-<stamp>/ (a .bak folder inside skills/ would still load).
say 'Installing skills...'
SKILL_BAK="$CLAUDE/skills-backup-$STAMP"
for d in "$ROOT"/skills/*/; do
  name="$(basename "$d")"; dst="$SKILLS_DST/$name"
  if [ -d "$dst" ]; then
    if diff -rq "$d" "$dst" >/dev/null 2>&1; then SAME=$((SAME+1)); continue; fi
    mkdir -p "$SKILL_BAK"; mv "$dst" "$SKILL_BAK/$name"; BAK=$((BAK+1)); c 33 "  backed up your skill $name -> $SKILL_BAK"
  else NEW=$((NEW+1)); fi
  cp -R "${d%/}" "$dst"
done

# --- CLAUDE.md section between markers (replaced on re-run, never duplicated) ---
CMD="$CLAUDE/CLAUDE.md"
SNIP="$ROOT/CLAUDE-SNIPPET.md"
BLOCKF="$(mktemp)"; { echo "$BEGIN"; cat "$SNIP"; echo; echo "$END"; } > "$BLOCKF"
OUTF="$(mktemp)"
if [ -f "$CMD" ] && grep -qF "$BEGIN" "$CMD"; then
  awk -v b="$BEGIN" -v e="$END" -v bf="$BLOCKF" '
    $0==b { while ((getline l < bf) > 0) print l; skip=1; next }
    skip && $0==e { skip=0; next }
    !skip { print }' "$CMD" > "$OUTF"
  MSG='Updated the Studio Kit section in'
else
  { [ -f "$CMD" ] && [ -s "$CMD" ] && { cat "$CMD"; echo; }; cat "$BLOCKF"; } > "$OUTF" || true
  MSG='Added the Studio Kit section to'
fi
if [ -f "$CMD" ] && cmp -s "$OUTF" "$CMD"; then c 90 'CLAUDE.md section already current.'
else [ -f "$CMD" ] && cp "$CMD" "$CMD.bak-$STAMP"; mv "$OUTF" "$CMD"; c 32 "$MSG $CMD"; fi
rm -f "$BLOCKF" "$OUTF"

# --- optional: 21st.dev MCP from the encrypted key file ---
# Format (secrets/21st.enc): PBKDF2-SHA256(passphrase, salt, iter) -> 64 bytes =
# AES-256-CBC key | HMAC-SHA256 key; mac = HMAC(iv || ciphertext). Decrypted in memory only.
field() { sed -n "s/^$1=//p" "$ENC" | tr -d '\r\n'; }
unlock_key() {  # prints the key on stdout, or returns 1 on a wrong passphrase
  local salt iv ct mac iter
  salt="$(field salt)"; iv="$(field iv)"; ct="$(field ct)"; mac="$(field mac)"; iter="$(field iter)"
  if command -v python3 >/dev/null 2>&1; then
    local ek
    ek="$(SK_PASS="$PASS" SK_SALT="$salt" SK_IV="$iv" SK_CT="$ct" SK_MAC="$mac" SK_ITER="$iter" python3 -I -c '
import os,re,hashlib,hmac,base64,sys
p=re.sub(r"[^a-z0-9]","",os.environ["SK_PASS"].lower()).encode()
dk=hashlib.pbkdf2_hmac("sha256",p,bytes.fromhex(os.environ["SK_SALT"]),int(os.environ["SK_ITER"]),64)
m=hmac.new(dk[32:],bytes.fromhex(os.environ["SK_IV"])+base64.b64decode(os.environ["SK_CT"]),hashlib.sha256).hexdigest()
if not hmac.compare_digest(m,os.environ["SK_MAC"]): sys.exit(1)
print(dk[:32].hex())')" || return 1
    printf '%s' "$ct" | openssl enc -d -aes-256-cbc -K "$ek" -iv "$iv" -base64 -A
  elif command -v node >/dev/null 2>&1; then
    SK_PASS="$PASS" SK_SALT="$salt" SK_IV="$iv" SK_CT="$ct" SK_MAC="$mac" SK_ITER="$iter" node -e '
const c=require("crypto"),e=process.env;
const p=e.SK_PASS.toLowerCase().replace(/[^a-z0-9]/g,"");
const dk=c.pbkdf2Sync(p,Buffer.from(e.SK_SALT,"hex"),+e.SK_ITER,64,"sha256");
const iv=Buffer.from(e.SK_IV,"hex"),ct=Buffer.from(e.SK_CT,"base64");
const m=c.createHmac("sha256",dk.subarray(32)).update(Buffer.concat([iv,ct])).digest();
const w=Buffer.from(e.SK_MAC,"hex");
if(m.length!==w.length||!c.timingSafeEqual(m,w))process.exit(1);
const d=c.createDecipheriv("aes-256-cbc",dk.subarray(0,32),iv);
process.stdout.write(Buffer.concat([d.update(ct),d.final()]).toString("utf8"));' || return 1
  else
    c 33 '  needs python3 or node to unlock the key file - skipped'; return 3
  fi
}

MCP_RESULT='skipped'
ENC="$ROOT/secrets/21st.enc"
if [ "${STUDIOKIT_SKIP_21ST:-}" = '1' ]; then
  c 90 '21st.dev MCP: skipped (STUDIOKIT_SKIP_21ST=1).'
elif [ ! -f "$ENC" ]; then
  c 90 '21st.dev MCP: no key file in this kit - skipped.'
elif ! command -v claude >/dev/null 2>&1; then
  c 33 '21st.dev MCP: the claude command is not on PATH - install Claude Code, then re-run this.'
else
  PASS="${STUDIOKIT_PASSPHRASE:-}"
  if [ -z "$PASS" ] && [ -r /dev/tty ] && [ -t 1 ]; then
    printf 'Passphrase you were texted for the 21st.dev key (Enter to skip): ' > /dev/tty
    IFS= read -rs PASS < /dev/tty || PASS=''; echo > /dev/tty
  fi
  if [ -z "$PASS" ]; then
    c 90 '21st.dev MCP: no passphrase given - skipped. Re-run with STUDIOKIT_PASSPHRASE set to add it.'
  else
    set +e; KEY="$(unlock_key)"; rc=$?; set -e
    if [ $rc -eq 1 ] || { [ $rc -eq 0 ] && [ -z "$KEY" ]; }; then
      c 31 '21st.dev MCP: WRONG PASSPHRASE - nothing was changed. Check the text and run again.'
      MCP_RESULT='wrong-passphrase'
    elif [ $rc -eq 0 ]; then
      if claude mcp get 21st >/dev/null 2>&1 && [ "${STUDIOKIT_REPLACE_21ST:-}" != '1' ]; then
        c 33 '21st.dev MCP: you already have a "21st" server - left it alone (STUDIOKIT_REPLACE_21ST=1 replaces it).'
        MCP_RESULT='already-present'
      else
        claude mcp remove 21st -s user >/dev/null 2>&1 || true
        claude mcp add --transport http --scope user 21st https://21st.dev/api/mcp --header "x-api-key: $KEY" >/dev/null 2>&1 || true
        if claude mcp list 2>/dev/null | grep -q '^21st:'; then
          c 32 '21st.dev MCP: registered (user scope) and listed by "claude mcp list".'; MCP_RESULT='registered'
        else c 31 '21st.dev MCP: add ran but "claude mcp list" does not show it - run: claude mcp list'; MCP_RESULT='not-listed'; fi
      fi
    fi
    KEY=''; PASS=''
  fi
fi

AGENT_COUNT="$(find "$AGENTS_DST" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
SKILL_COUNT="$(find "$SKILLS_DST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo
c 32 '  Done.'
c 32 "  $AGENT_COUNT agent + doc files in $AGENTS_DST"
c 32 "  $SKILL_COUNT skills in $SKILLS_DST"
c 32 "  this run: $NEW new, $SAME already current, $BAK of yours backed up"
c 32 "  21st.dev MCP: $MCP_RESULT"
echo
c 1 'Next: restart Claude Code, then say:'
c 1 '  act as delivery-lead and read PLAYBOOK.md, I am building <your app>'
echo
[ "$MCP_RESULT" = 'wrong-passphrase' ] && exit 2
exit 0
