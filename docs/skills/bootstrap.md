# Eagle Bootstrap

One-time global environment setup for Claude Code.

## What it does

Run this once per machine to configure your Claude Code environment:

1. **Behavioral rules** — Appends four principles to `~/.claude/CLAUDE.md`: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution
2. **Compact hook system** — Installs the self-growing token saver: command rewriter, output filters, and auto-growing observer ([details](../compact-hook.md))
3. **Obsidian vault** — Configures and saves your vault path for wiki integration
4. **Claude Mem** — Verifies the Claude Mem plugin is installed (guides to marketplace if not)
5. **Eagle agents** — Verifies all 14 eagle-skills agents are installed

## Command

```
/eagle-bootstrap
```

Also triggers on: "eagle bootstrap", "setup my environment", "first time setup", "configure claude globally"

## Output

```
eagle-bootstrap complete:
  CLAUDE.md:    enriched | already has behavioral rules
  compact.sh:   installed | already installed
  Obsidian:     configured (<path>) | skipped (not installed)
  Claude Mem:   installed | not installed — install from marketplace
  Eagle agents: 14/14 installed | n/14 — run eagle-skills install
```

## Idempotent

Every step checks its own state before acting. Running twice produces the same result as running once.
