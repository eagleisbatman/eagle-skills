# Compact Hook System

A self-growing token-saving system for Claude Code. Three hooks work together: one rewrites verbose commands, one filters noisy output, and one silently learns which new commands need rules.

## Architecture

```
                 ┌─────────────────────┐
                 │   compact-rules.json │  ◄── /eagle-compact-add promotes here
                 │   (32+ regex rules)  │
                 └──────┬──────────────┘
                        │ reads
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
  ┌──────────┐   ┌──────────────┐  ┌──────────────────┐
  │compact.sh│   │compact-filter│  │compact-observer.sh│
  │PreToolUse│   │  .sh (pipe)  │  │   PostToolUse     │
  └──────────┘   └──────────────┘  └────────┬─────────┘
        │               ▲                   │ logs
        │               │                   ▼
        │          piped through    ┌───────────────────┐
        └──────────────────────►   │compact-candidates  │
           rewrites commands       │     .json          │
                                   └───────────────────┘
```

## How it works

### 1. Command rewriting (compact.sh — PreToolUse)

Before every Bash command, `compact.sh` checks the command against regex patterns in `compact-rules.json`. Two rule types:

**Flag rules** — rewrite the command to produce less output (lossless):
```json
{"pattern": "^git log$", "type": "flag", "rewrite": "git log --oneline -n 20"}
```

**Pipe rules** — pipe output through `compact-filter.sh` for compression:
```json
{"pattern": "^pytest\\b", "type": "pipe", "filter": "pytest"}
```

Safety guards skip compound commands (`&&`, `||`, pipes, redirects) to avoid breaking shell semantics.

### 2. Output filtering (compact-filter.sh)

When a pipe rule fires, output streams through specialized filters:

| Filter | What it keeps |
|--------|--------------|
| `pytest` | Summary + failed test details only |
| `test` | Generic test runner — pass/fail counts + failures |
| `cargo_test` | Rust test summary |
| `go_test` | Go test summary |
| `lint` | First 30 warnings + count |
| `tsc` | First 30 type errors + count |
| `cargo_build` | Errors + warnings only |
| `docker_logs` / `k8s_logs` | Last 50 lines |
| `generic` | Deduped, stripped, truncated to 100 lines |

All filters strip ANSI escape codes and deduplicate repeated lines (e.g., `[repeated 47 times]`).

### 3. Auto-growing observer (compact-observer.sh — PostToolUse)

This is the learning layer. After every Bash command, the observer silently checks:

1. **Was the output verbose?** (30+ lines of stdout + stderr)
2. **Was it already handled?** (compact-filter.sh in the command, or matches an existing rule)
3. **Is it a compound command?** (pipes, redirects, `&&` — can't be safely rewritten)

If a command passes all checks — verbose, uncovered, simple — it gets logged to `compact-candidates.json`:

```json
[
  {
    "key": "find",
    "count": 12,
    "sample_cmd": "find . -type f -name '*.ts'",
    "sample_lines": 340,
    "last_seen": "2026-04-24T10:30:00Z"
  }
]
```

The observer deduplicates by command key (first 1-2 tokens). Repeated commands increment the count and upgrade the sample to the most verbose invocation. Multi-word CLIs like `git`, `docker`, `npm` use two tokens for the key (e.g., `git stash`, `docker exec`).

**Performance:** Checks are ordered cheapest-first (line count arithmetic before jq regex matching). The observer is fail-open — any error exits silently without affecting the session.

**Concurrency:** Uses mkdir-based locking (atomic and portable) so multiple Claude Code sessions don't corrupt the candidates file.

### 4. Rule promotion (/eagle-compact-add skill)

When you're ready, run `/eagle-compact-add` to review accumulated candidates. The skill:

1. Shows candidates ranked by frequency
2. Proposes a rule type for each (flag vs pipe)
3. Validates the regex pattern compiles and matches
4. Asks you to confirm before writing
5. Appends approved rules to `compact-rules.json`
6. Clears promoted candidates

Only candidates with count >= 2 are proposed — one-off commands aren't worth a permanent rule.

## Files

All files live in `~/.claude/hooks/`:

| File | Purpose |
|------|---------|
| `compact.sh` | PreToolUse hook — reads rules, rewrites commands |
| `compact-filter.sh` | Output filter with 9 specialized functions |
| `compact-rules.json` | Rule database (32 rules, grows via /eagle-compact-add) |
| `compact-observer.sh` | PostToolUse hook — logs uncovered verbose commands |
| `compact-candidates.json` | Candidate log (auto-populated, reviewed via skill) |

## Installation

Run `/eagle-bootstrap` — it installs everything and wires both hooks into `~/.claude/settings.json`.

Or manually:
```bash
# Copy from eagle-skills repo
cp eagle-bootstrap/references/compact*.sh ~/.claude/hooks/
cp eagle-bootstrap/references/compact-rules.json ~/.claude/hooks/
chmod +x ~/.claude/hooks/compact.sh ~/.claude/hooks/compact-filter.sh ~/.claude/hooks/compact-observer.sh
echo '[]' > ~/.claude/hooks/compact-candidates.json
```

Then add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/compact.sh"}]}],
    "PostToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/compact-observer.sh"}]}]
  }
}
```

## After installation

**Restart all open Claude Code sessions.** Hooks are loaded from `settings.json` at session start. Existing sessions won't pick up the new PostToolUse observer until restarted.

## Troubleshooting

**Observer stopped logging candidates:**
```bash
rmdir ~/.claude/hooks/compact-candidates.json.lock 2>/dev/null
```
A stale lock directory can persist if the observer process was killed mid-write (rare).

**Check if observer is wired:**
```bash
grep "compact-observer" ~/.claude/settings.json
```

**View current candidates:**
```bash
cat ~/.claude/hooks/compact-candidates.json | jq .
```

**View current rules:**
```bash
cat ~/.claude/hooks/compact-rules.json | jq length
# → 32 (or more, if you've promoted candidates)
```
