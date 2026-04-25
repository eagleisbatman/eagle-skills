# Compact Hook System

A token-saving system for Claude Code. A PreToolUse hook rewrites verbose Bash commands using regex rules, and an output filter compresses noisy build/test output.

## Architecture

```
  ┌─────────────────────┐
  │   compact-rules.json │  ◄── /eagle-compact-add adds rules here
  │   (32 regex rules)   │
  └──────┬──────────────┘
         │ reads
         ▼
  ┌──────────┐   ┌──────────────┐
  │compact.sh│   │compact-filter│
  │PreToolUse│   │  .sh (pipe)  │
  └──────────┘   └──────────────┘
       │               ▲
       │               │
       └───────────────┘
         rewrites commands
         or pipes through filter
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
| `cargo-test` | Rust test summary |
| `go-test` | Go test summary |
| `lint` | Matching warnings and errors |
| `tsc` | Type errors |
| `cargo-build` | Errors + warnings only |
| `docker-logs` / `k8s-logs` | Stripped and deduped lines |
| `generic` | Stripped and deduped lines |

All filters strip ANSI escape codes and deduplicate repeated lines (e.g., `[repeated 47 times]`).

### 3. Adding rules (/eagle-compact-add)

Run `/eagle-compact-add` to manually add rules for commands you find verbose. The skill helps you design the regex pattern and validates it before writing.

## Files

All files live in `~/.claude/hooks/`:

| File | Purpose |
|------|---------|
| `compact.sh` | PreToolUse hook — reads rules, rewrites commands |
| `compact-filter.sh` | Output filter with 10 specialized functions |
| `compact-rules.json` | Rule database (32 rules, grows via /eagle-compact-add) |

## Installation

Run `/eagle-bootstrap` — it installs everything and wires the hook into `~/.claude/settings.json`.

Or manually:
```bash
cp eagle-bootstrap/references/compact.sh ~/.claude/hooks/
cp eagle-bootstrap/references/compact-rules.json ~/.claude/hooks/
cp eagle-bootstrap/references/compact-filter.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/compact.sh ~/.claude/hooks/compact-filter.sh
```

Then add to `~/.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "~/.claude/hooks/compact.sh"}]}]
  }
}
```

## Troubleshooting

**Check if hook is wired:**
```bash
grep "compact.sh" ~/.claude/settings.json
```

**View current rules:**
```bash
cat ~/.claude/hooks/compact-rules.json | jq length
# → 32 (or more, if you've added rules via /eagle-compact-add)
```
