---
name: eagle-compact-add
description: >
  Review and promote compact-observer candidates into compact-rules.json.
  Use when the user says: 'review compact candidates', 'add compact rules',
  'grow compact database', 'check compact observer', 'what commands need compacting',
  'compact-add', 'show compact candidates', 'promote candidates'.
---

# Eagle Compact Add

Review commands flagged by the compact-observer and promote worthy ones into compact-rules.json.

## How it works

The `compact-observer.sh` PostToolUse hook silently watches every Bash command Claude Code runs. When a command produces verbose output (30+ lines) and isn't already covered by a rule, the observer logs it to `~/.claude/hooks/compact-candidates.json` with deduplication.

This skill reviews those candidates and proposes new rules.

## Workflow

### 1. Read candidates

Read `~/.claude/hooks/compact-candidates.json`. If empty or missing, report:
> No candidates yet — the observer hasn't flagged any uncovered verbose commands.

### 2. Show candidates

Display candidates sorted by count (most frequent first). Each candidate has a `samples` array (up to 5 structurally different commands observed under that key). Show all variants:

| Key | Count | Last Seen |
|-----|-------|-----------|

Under each key, list its samples:
```
  1. <cmd> (42 lines)
  2. <cmd> (87 lines)
```

### 3. Analyze samples and propose rules for candidates with count >= 2

For each qualifying candidate, study the samples array to decide:

**Pattern specificity** — If all samples share a common structure (e.g., all start with `psql -c`), write a specific pattern. If samples are wildly different (e.g., `node build.js` vs `node server.js`), the key is too coarse for a single rule — skip it or propose multiple rules for distinct subgroups.

**Compound commands** — If a sample contains shell operators (`&&`, `||`, `;`, `|`, `>`, `<`, `$(`, backticks), neither flag nor pipe rules can safely cover it. Flag rules replace the entire command string (destroying the compound structure), and pipe rules are skipped by compact.sh for compound commands. Compound samples are observed for visibility — note them as "observed but not covered" in the summary. Only propose rules based on the simple (non-compound) samples.

**Rule type:**

**Flag rule** — when the command supports truncation flags (`-n`, `--limit`, `--max-count`, `--head`, `--tail`, `-l`). The rewrite adds a reasonable limit to cap output. Preferred when possible — lossless and faster. Always anchor with `^...$` to prevent partial matches on compound commands.

```json
{"pattern": "^git log\\b", "type": "flag", "rewrite": "git log --oneline -n 20"}
```

**Pipe rule** — when the output needs filtering (test results, build logs, lint output). Only works for simple (non-compound) commands. Choose the appropriate filter from compact-filter.sh or use `generic` if no specific filter fits.

Available filters: `pytest`, `test`, `cargo_test`, `go_test`, `lint`, `tsc`, `cargo_build`, `docker_logs`, `k8s_logs`, `generic`

```json
{"pattern": "^pytest\\b", "type": "pipe", "filter": "pytest"}
```

### 4. Validate each proposed rule

For every proposed pattern, test it against every non-compound entry in the candidate's `samples[].cmd`:
```bash
echo '' | jq --arg cmd "<sample_cmd>" 'if ($cmd | test("<pattern>")) then "MATCH" else "NO MATCH" end'
```
All non-compound samples must match. Compound samples should NOT match (if they do, the pattern lacks proper anchoring).

Also test against 2-3 unrelated commands (e.g., `ls`, `echo hello`, `cat file.txt`) to verify no false positives.

### 5. Confirm with user

Show all proposed rules in a summary table before writing anything. Wait for user confirmation.

### 6. Append rules

Use jq to append confirmed rules to `~/.claude/hooks/compact-rules.json`:
```bash
jq '. + [<new_rules>]' ~/.claude/hooks/compact-rules.json > /tmp/compact-rules-updated.json && \
  mv /tmp/compact-rules-updated.json ~/.claude/hooks/compact-rules.json
```

Verify the file is valid JSON after writing:
```bash
jq empty ~/.claude/hooks/compact-rules.json
```

### 7. Clean up processed candidates

Remove promoted candidates (count >= 2 that were converted to rules) from compact-candidates.json. Keep candidates with count < 2 — they need more observations before promotion.

### 8. Sync repo copy

If the current project is eagle-skills, also update `eagle-bootstrap/references/compact-rules.json` to match the installed version.

## Guidelines

- Only propose rules for candidates with count >= 2 (one-off commands aren't worth a permanent rule)
- Prefer flag rules when possible — they're lossless and faster than pipe-through
- Use `\b` word boundaries in patterns to avoid partial matches
- Use `^` anchors when the command is always at the start
- Never propose rules for commands that are inherently variable (e.g., `curl` with different URLs)
- If a candidate is noise (e.g., a one-time debug command that happened to repeat), skip it and remove from candidates

## Troubleshooting

If the observer stops logging candidates, check for a stale lock directory:
```bash
rmdir ~/.claude/hooks/compact-candidates.json.lock 2>/dev/null
```
This can happen if the observer process is killed mid-write (rare — only on crash or force-quit).
