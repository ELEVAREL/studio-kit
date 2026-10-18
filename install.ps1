# Studio Kit - agent team installer for Claude Code (Windows)
# ------------------------------------------------------------------
# One command (PowerShell):
#   irm https://raw.githubusercontent.com/ELEVAREL/studio-kit/main/install.ps1 | iex
# Or from a local copy of this repo:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
#
# Installs agents + operating docs into ~/.claude/agents, skills into ~/.claude/skills,
# and adds a "Studio Kit" section to ~/.claude/CLAUDE.md. Needs no API keys.
# Nothing you already have is overwritten: a file that differs is backed up first.
#
# Optional: the 21st.dev component MCP. If you were given a passphrase, set it first:
#   $env:STUDIOKIT_PASSPHRASE = 'xxxx-xxxx-...' ; irm .../install.ps1 | iex
# or run interactively and type it when asked. Wrong passphrase = nothing changes.
#
# Env overrides (for testing): STUDIOKIT_HOME (target home dir), STUDIOKIT_SKIP_21ST=1

$ErrorActionPreference = 'Stop'
function Say($m, $c = 'Cyan') { Write-Host $m -ForegroundColor $c }

$Marker  = 'studio-kit'
$Begin   = "<!-- $Marker`:begin -->"
$End     = "<!-- $Marker`:end -->"
$ZipUrl  = 'https://codeload.github.com/ELEVAREL/studio-kit/zip/refs/heads/main'

Say ''
Say '==============================================' 'DarkCyan'
Say '  Studio Kit  ->  Claude Code agent installer' 'White'
Say '==============================================' 'DarkCyan'

# --- target home (USERPROFILE, not $HOME, so it can be redirected for tests) ---
$homeDir = if ($env:STUDIOKIT_HOME) { $env:STUDIOKIT_HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$claude    = Join-Path $homeDir '.claude'
$agentsDst = Join-Path $claude 'agents'
$skillsDst = Join-Path $claude 'skills'
New-Item -ItemType Directory -Force -Path $claude, $agentsDst, $skillsDst | Out-Null
Say "Target: $claude" 'Gray'

# --- source: local clone, or download the repo zip ---
$tmp = $null
$here = $PSScriptRoot
if ($here -and (Test-Path (Join-Path $here 'agents')) -and (Test-Path (Join-Path $here 'skills'))) {
  $root = $here; Say "Installing from local copy: $root"
} else {
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ('studio-kit-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  $zip = Join-Path $tmp 'kit.zip'
  Say 'Downloading the kit from GitHub...'
  try { $ProgressPreference = 'SilentlyContinue' } catch {}
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-WebRequest -UseBasicParsing -Uri $ZipUrl -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
  $root = Join-Path $tmp 'studio-kit-main'
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$stats = @{ new = 0; same = 0; backedUp = 0 }

function Same-File($a, $b) {
  if (-not (Test-Path $b)) { return $false }
  if ((Get-Item $a).Length -ne (Get-Item $b).Length) { return $false }
  return ((Get-FileHash $a).Hash -eq (Get-FileHash $b).Hash)
}

# --- agents + docs: per file; a differing file is renamed to <name>.bak-<stamp> ---
Say 'Installing agents + operating docs...'
Get-ChildItem -Path (Join-Path $root 'agents') -File | ForEach-Object {
  $dst = Join-Path $agentsDst $_.Name
  if (Test-Path $dst) {
    if (Same-File $_.FullName $dst) { $stats.same++; return }
    Move-Item $dst "$dst.bak-$stamp" -Force; $stats.backedUp++
    Say "  backed up your $($_.Name) -> $($_.Name).bak-$stamp" 'Yellow'
  } else { $stats.new++ }
  Copy-Item $_.FullName $dst -Force
}
$bg = Join-Path $root 'BUILD-GUIDE.md'
if (Test-Path $bg) {
  $dst = Join-Path $agentsDst 'BUILD-GUIDE.md'
  if ((Test-Path $dst) -and -not (Same-File $bg $dst)) { Move-Item $dst "$dst.bak-$stamp" -Force; $stats.backedUp++ }
  Copy-Item $bg $dst -Force
}

# --- skills: per skill folder. A differing folder you already have is MOVED to
#     ~/.claude/skills-backup-<stamp>/ (a .bak folder inside skills/ would still load).
Say 'Installing skills...'
$skillBak = Join-Path $claude "skills-backup-$stamp"
Get-ChildItem -Path (Join-Path $root 'skills') -Directory | ForEach-Object {
  $src = $_.FullName; $dst = Join-Path $skillsDst $_.Name
  if (Test-Path $dst) {
    $diff = $false
    $srcFiles = Get-ChildItem $src -Recurse -File
    foreach ($f in $srcFiles) {
      $rel = $f.FullName.Substring($src.Length).TrimStart('\','/')
      if (-not (Same-File $f.FullName (Join-Path $dst $rel))) { $diff = $true; break }
    }
    if (-not $diff -and ((Get-ChildItem $dst -Recurse -File | Measure-Object).Count -eq $srcFiles.Count)) { $stats.same++; return }
    New-Item -ItemType Directory -Force -Path $skillBak | Out-Null
    Move-Item $dst (Join-Path $skillBak $_.Name) -Force; $stats.backedUp++
    Say "  backed up your skill $($_.Name) -> $skillBak" 'Yellow'
  } else { $stats.new++ }
  Copy-Item $src $dst -Recurse -Force
}

# --- CLAUDE.md section between markers (replaced on re-run, never duplicated) ---
$claudeMd = Join-Path $claude 'CLAUDE.md'
$snippet  = (Get-Content (Join-Path $root 'CLAUDE-SNIPPET.md') -Raw).Trim()
$block    = "$Begin`n$snippet`n$End"
$existing = if (Test-Path $claudeMd) { Get-Content $claudeMd -Raw } else { '' }
if ($null -eq $existing) { $existing = '' }
$rx = [regex]::Escape($Begin) + '[\s\S]*?' + [regex]::Escape($End)
if ($existing -match $rx) {
  $new = [regex]::Replace($existing, $rx, { param($m) $block })
  $msg = 'Updated the Studio Kit section in'
} else {
  $sep = if ($existing.Trim().Length) { "`n`n" } else { '' }
  $new = $existing.TrimEnd() + $sep + $block + "`n"
  $msg = 'Added the Studio Kit section to'
}
if ($new -ne $existing) {
  if (Test-Path $claudeMd) { Copy-Item $claudeMd "$claudeMd.bak-$stamp" -Force }
  [IO.File]::WriteAllText($claudeMd, $new)
  Say "$msg $claudeMd" 'Green'
} else { Say 'CLAUDE.md section already current.' 'Gray' }

# --- optional: 21st.dev MCP from the encrypted key file ---
function Hex2Bytes([string]$h) { $b = New-Object byte[] ($h.Length / 2); for ($i = 0; $i -lt $b.Length; $i++) { $b[$i] = [Convert]::ToByte($h.Substring($i * 2, 2), 16) }; return ,$b }
function Unlock-Key([string]$file, [string]$pass) {
  $f = @{}; foreach ($l in (Get-Content $file)) { if ($l -match '^(\w+)=(.*)$') { $f[$matches[1]] = $matches[2].Trim() } }
  $norm = ($pass.ToLower() -replace '[^a-z0-9]', '')
  $kdf = New-Object Security.Cryptography.Rfc2898DeriveBytes($norm, (Hex2Bytes $f.salt), [int]$f.iter, [Security.Cryptography.HashAlgorithmName]::SHA256)
  $dk = $kdf.GetBytes(64); $ek = [byte[]]$dk[0..31]; $mk = [byte[]]$dk[32..63]
  $iv = Hex2Bytes $f.iv; $ct = [Convert]::FromBase64String($f.ct)
  $mac = (New-Object Security.Cryptography.HMACSHA256(,$mk)).ComputeHash([byte[]]($iv + $ct))
  $want = Hex2Bytes $f.mac
  $ok = $mac.Length -eq $want.Length; $d = 0; for ($i = 0; $i -lt $mac.Length; $i++) { $d = $d -bor ($mac[$i] -bxor $want[$i]) }
  if (-not $ok -or $d -ne 0) { return $null }
  $aes = [Security.Cryptography.Aes]::Create(); $aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'; $aes.Key = $ek; $aes.IV = $iv
  return [Text.Encoding]::UTF8.GetString($aes.CreateDecryptor().TransformFinalBlock($ct, 0, $ct.Length))
}

$mcpResult = 'skipped'
$encFile = Join-Path $root 'secrets/21st.enc'
$claudeCli = Get-Command claude -ErrorAction SilentlyContinue
if ($env:STUDIOKIT_SKIP_21ST -eq '1') {
  Say '21st.dev MCP: skipped (STUDIOKIT_SKIP_21ST=1).' 'Gray'
} elseif (-not (Test-Path $encFile)) {
  Say '21st.dev MCP: no key file in this kit - skipped.' 'Gray'
} elseif (-not $claudeCli) {
  Say '21st.dev MCP: the claude command is not on PATH - install Claude Code, then re-run this.' 'Yellow'
} else {
  $pass = $env:STUDIOKIT_PASSPHRASE
  if (-not $pass -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    try {
      $sec = Read-Host -Prompt 'Passphrase you were texted for the 21st.dev key (Enter to skip)' -AsSecureString
      $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
      try { $pass = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    } catch { $pass = $null }
  }
  if (-not $pass) {
    Say '21st.dev MCP: no passphrase given - skipped. Re-run with $env:STUDIOKIT_PASSPHRASE set to add it.' 'Gray'
  } else {
    $key = Unlock-Key $encFile $pass
    if (-not $key) {
      Say '21st.dev MCP: WRONG PASSPHRASE - nothing was changed. Check the text and run again.' 'Red'
      $mcpResult = 'wrong-passphrase'
    } else {
      $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
      & claude mcp get 21st *> $null
      $exists = ($LASTEXITCODE -eq 0)
      if ($exists -and $env:STUDIOKIT_REPLACE_21ST -ne '1') {
        Say '21st.dev MCP: you already have a "21st" server - left it alone (set STUDIOKIT_REPLACE_21ST=1 to replace).' 'Yellow'
        $mcpResult = 'already-present'
      } else {
        if ($exists) { & claude mcp remove 21st -s user *> $null }
        & claude mcp add --transport http --scope user 21st https://21st.dev/api/mcp --header "x-api-key: $key" *> $null
        $listed = (& claude mcp list 2>$null | Out-String)
        if ($listed -match '(?m)^21st:') { Say '21st.dev MCP: registered (user scope) and listed by "claude mcp list".' 'Green'; $mcpResult = 'registered' }
        else { Say '21st.dev MCP: add ran but "claude mcp list" does not show it - run: claude mcp list' 'Red'; $mcpResult = 'not-listed' }
      }
      $ErrorActionPreference = $prev
    }
    $key = $null; $pass = $null; [GC]::Collect()
  }
}

# --- counts + cleanup ---
$agentCount = (Get-ChildItem -Path $agentsDst -Filter '*.md' -File | Measure-Object).Count
$skillCount = (Get-ChildItem -Path $skillsDst -Directory | Measure-Object).Count
if ($tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }

Say ''
Say '  Done.' 'Green'
Say "  $agentCount agent + doc files in $agentsDst" 'Green'
Say "  $skillCount skills in $skillsDst" 'Green'
Say "  this run: $($stats.new) new, $($stats.same) already current, $($stats.backedUp) of yours backed up" 'Green'
Say "  21st.dev MCP: $mcpResult" 'Green'
Say ''
Say 'Next: restart Claude Code, then say:' 'White'
Say '  act as delivery-lead and read PLAYBOOK.md, I am building <your app>' 'White'
Say ''
if ($mcpResult -eq 'wrong-passphrase') {
  # exit only when run as a file; under "irm | iex" an exit would close the window
  if ($PSCommandPath) { exit 2 } else { $global:LASTEXITCODE = 2 }
}
