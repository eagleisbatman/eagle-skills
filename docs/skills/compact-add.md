# Eagle Compact Add

Review and promote auto-observed command candidates into the compact rules database.

## What it does

The [compact hook system](../compact-hook.md) silently watches every Bash command Claude Code runs. When a command produces verbose output (30+ lines) and isn't covered by an existing rule, it gets logged as a candidate.

This skill reviews those candidates, proposes new rules, and adds them to `compact-rules.json` after your confirmation.

## Command

```
/eagle-compact-add
```

Also triggers on: "review compact candidates", "add compact rules", "grow compact database", "show compact candidates", "promote candidates"

## Workflow

1. Reads `~/.claude/hooks/compact-candidates.json`
2. Shows candidates sorted by frequency (most-seen first)
3. For candidates with count >= 2, proposes a rule:
   - **Flag rule** if truncation flags exist (`-n`, `--limit`, `--max-count`)
   - **Pipe rule** if output needs filtering (test results, build logs, lint)
4. Validates each regex pattern against the sample command
5. Shows proposed rules for your confirmation
6. Appends confirmed rules and clears promoted candidates

## Output

```
Candidates (3 found):
  find       ×12  sample: find . -type f -name '*.ts'    (340 lines)
  cat        ×8   sample: cat src/index.ts               (450 lines)
  terraform  ×3   sample: terraform plan                 (200 lines)

Proposed rules:
  find       → pipe:generic  pattern: ^find\b
  terraform  → pipe:generic  pattern: ^terraform plan\b

Confirm? [y/N]
```

## No inputs required

The skill reads `~/.claude/hooks/compact-candidates.json` automatically. If no candidates exist yet, it reports that the observer hasn't flagged anything.
