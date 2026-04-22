---
name: eagle-bootstrap
description: >
  One-time global environment setup for Claude Code. Use when the user says: 'eagle bootstrap',
  'setup my environment', 'eagle setup', 'first time setup', 'configure claude globally',
  'install eagle environment', 'set up my machine for claude'. This skill enriches the global
  ~/.claude/CLAUDE.md with behavioral rules, installs the compact.sh token-saving hook, configures
  the Obsidian vault path, verifies Claude Mem plugin, and confirms eagle-skills agents are
  installed. Run once per machine — safe to re-run (idempotent, skips what's already done).
---

# Eagle Bootstrap

One-time global setup that configures your Claude Code environment. Every step is idempotent — safe to re-run, skips what's already done.

## What it does

1. Enriches `~/.claude/CLAUDE.md` with behavioral rules (without overwriting existing content)
2. Installs the `compact.sh` PreToolUse hook (saves tokens on verbose bash commands)
3. Configures the Obsidian vault path for wiki integration
4. Verifies the Claude Mem plugin is installed
5. Verifies eagle-skills agents are installed

## Process

### Step 1: Enrich global CLAUDE.md

**Detection:** Read `~/.claude/CLAUDE.md`. Check for the marker heading `## Behavioral Rules`.

If the section is missing, **append** it. Never modify existing sections.

Append the content from `references/behavioral-rules.md` to the end of `~/.claude/CLAUDE.md`.

**Important:**
- Read the full file first. Preserve every existing line.
- Only append — never reorder, edit, or remove existing sections.
- If the file doesn't exist, create it with just the behavioral rules section (other sections will come from eagle-skills or user configuration).

### Step 2: Install compact.sh hook

**Detection:** Check if `~/.claude/hooks/compact.sh` exists AND `~/.claude/settings.json` has a PreToolUse hook referencing it.

If missing, do both:

1. **Copy the hook script:**
   ```bash
   mkdir -p ~/.claude/hooks
   cp <skill-path>/references/compact.sh ~/.claude/hooks/compact.sh
   chmod +x ~/.claude/hooks/compact.sh
   ```

2. **Merge hook config into settings.json:**
   Read `~/.claude/settings.json`. Use `jq` to merge the hooks key without clobbering other settings:

   ```bash
   jq '.hooks.PreToolUse += [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/compact.sh"}]}]' \
     ~/.claude/settings.json > /tmp/settings-merged.json && \
     mv /tmp/settings-merged.json ~/.claude/settings.json
   ```

   If `settings.json` has no `hooks` key at all, the jq expression handles it (creates the key). If it already has PreToolUse hooks, the new one is appended to the array.

   **Check for duplicates:** Before merging, grep the file for `compact.sh`. If already present, skip.

### Step 3: Configure Obsidian vault path

**Detection:** Check if `~/.claude/eagle-config.json` exists and has an `obsidianVaultPath` value.

If missing:

1. Check if Obsidian is installed: `ls /Applications/Obsidian.app`
2. Probe for existing vaults:
   - `~/eaglevault/`
   - `~/Documents/Eagle Vault/`
   - `~/Obsidian/Eagle Vault/`
   - Any directory with a `.obsidian/` subdirectory in `~/` (one level deep)
3. If found, confirm with the user: "Found Obsidian vault at `<path>`. Use this?"
4. If not found, ask: "Where is your Obsidian vault? (full path)"
5. Save to config:
   ```json
   { "obsidianVaultPath": "<chosen-path>" }
   ```
6. Create the `projects/` directory in the vault if it doesn't exist:
   ```bash
   mkdir -p "<vault-path>/projects"
   ```

If Obsidian is not installed, note it and skip. The config file won't be created, so eagle-claude-md will also skip the vault step.

### Step 4: Verify Claude Mem plugin

**Detection:** Check `~/.claude/settings.json` for `"claude-mem@thedotmack": true` in `enabledPlugins`.

If present: report "Claude Mem: installed"

If missing: report "Claude Mem: not installed. Install it from the Claude Code marketplace: search for 'claude-mem' by thedotmack." Do NOT attempt to install it — plugin installation requires the Claude Code marketplace UI.

### Step 5: Verify eagle-skills agents

**Detection:** Check if `~/.claude/agents/` contains the expected agent files.

Expected agents (14 total):
- eagle-accessibility-review.md
- eagle-api-review.md
- eagle-architecture-review.md
- eagle-code-quality.md
- eagle-data-integrity.md
- eagle-database-review.md
- eagle-performance-review.md
- eagle-security-audit.md
- eagle-spectral-investigate.md
- eagle-spectral-plan.md
- eagle-spectral-ship.md
- eagle-spectral-suite.md
- eagle-triad-review.md
- eagle-ux-code-review.md

Count how many are present. Report:
- All 14 found → "Eagle agents: all 14 installed"
- Partial → "Eagle agents: <n>/14 installed. Missing: <list>. Run `eagle-skills install` to fix."
- None → "Eagle agents: not installed. Run `npx eagle-skills` or `eagle-skills install`."

### Step 6: Report

Print a summary:

```
eagle-bootstrap complete:
  CLAUDE.md:    <enriched | already has behavioral rules>
  compact.sh:   <installed | already installed>
  Obsidian:     <configured (<path>) | skipped (not installed)>
  Claude Mem:   <installed | not installed — install from marketplace>
  Eagle agents: <14/14 installed | n/14 — run eagle-skills install>
```

## Re-running

Every step independently checks its own state. Running eagle-bootstrap twice produces the same result as running it once. The second run should report all items as "already done" with no file modifications.
