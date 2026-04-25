---
name: eagle-compact-add
description: >
  Review and add new rules to compact-rules.json for the token-saving hook.
  Use when the user says: 'add compact rules', 'compact-add', 'add a compact rule',
  'this command is too verbose', 'compact this command', 'grow compact database'.
---

# Eagle Compact Add

Add new rules to compact-rules.json to make the token-saving hook cover more commands.

## How it works

The compact hook (`compact.sh`) rewrites verbose Bash commands before execution using regex rules. This skill helps you design and validate new rules for commands you find too verbose.

## Workflow

### 1. Identify the command

Ask the user which command they want to compact, or accept it as input. The user may say something like "this command is too verbose" after running a Bash command, or provide a specific command pattern.

### 2. Design the rule

Analyze the command to decide:

**Pattern specificity** — If all samples share a common structure (e.g., all start with `psql -c`), write a specific pattern. If samples are wildly different (e.g., `node build.js` vs `node server.js`), the key is too coarse for a single rule — skip it or propose multiple rules for distinct subgroups.

**Compound commands** — If a sample contains shell operators (`&&`, `||`, `;`, `|`, `>`, `<`, `$(`, backticks), neither flag nor pipe rules can safely cover it. Flag rules replace the entire command string (destroying the compound structure), and pipe rules are skipped by compact.sh for compound commands. Compound samples are observed for visibility — note them as "observed but not covered" in the summary. Only propose rules based on the simple (non-compound) samples.

**Rule type:**

**Flag rule** — when the command supports truncation flags (`-n`, `--limit`, `--max-count`, `--head`, `--tail`, `-l`). The rewrite adds a reasonable limit to cap output. Preferred when possible — lossless and faster. Always anchor with `^...$` to prevent partial matches on compound commands.

```json
{"pattern": "^git log\\b", "type": "flag", "rewrite": "git log --oneline -n 20"}
```

**Pipe rule** — when the output needs filtering (test results, build logs, lint output). Only works for simple (non-compound) commands. Choose the appropriate filter from compact-filter.sh or use `generic` if no specific filter fits.

Available filters: `pytest`, `test`, `cargo-test`, `go-test`, `lint`, `tsc`, `cargo-build`, `docker-logs`, `k8s-logs`, `generic`

```json
{"pattern": "^pytest\\b", "type": "pipe", "filter": "pytest"}
```

### 3. Validate the rule

For the proposed pattern, test it against the target command:
```bash
echo '' | jq --arg cmd "<sample_cmd>" 'if ($cmd | test("<pattern>")) then "MATCH" else "NO MATCH" end'
```

Also test against 2-3 unrelated commands (e.g., `ls`, `echo hello`, `cat file.txt`) to verify no false positives.

### 4. Confirm with user

Show the proposed rule before writing anything. Wait for user confirmation.

### 5. Append rules

Use jq to append confirmed rules to `~/.claude/hooks/compact-rules.json`:
```bash
jq '. + [<new_rules>]' ~/.claude/hooks/compact-rules.json > /tmp/compact-rules-updated.json && \
  mv /tmp/compact-rules-updated.json ~/.claude/hooks/compact-rules.json
```

Verify the file is valid JSON after writing:
```bash
jq empty ~/.claude/hooks/compact-rules.json
```

### 6. Sync repo copy

If the current project is eagle-skills, also update `eagle-bootstrap/references/compact-rules.json` to match the installed version.

## Guidelines

- Prefer flag rules when possible — they're lossless and faster than pipe-through
- Use `\b` word boundaries in patterns to avoid partial matches
- Use `^` anchors when the command is always at the start
- Never propose rules for commands that are inherently variable (e.g., `curl` with different URLs)
