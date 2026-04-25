# Eagle Bootstrap

One-time global environment setup for Claude Code.

## What it does

Run this once per machine to configure your Claude Code environment:

1. **Behavioral rules** — Appends four principles to `~/.claude/CLAUDE.md`: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution
2. **Compact hook system** — Installs the token saver: command rewriter, output filters, and 32 regex rules ([details](../compact-hook.md))
3. **Obsidian vault** — Configures and saves your vault path for wiki integration
4. **Eagle agents** — Verifies all 12 eagle-skills agents are installed

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
  Eagle agents: 12/12 installed | n/12 — run eagle-skills install
```

## Next step

After bootstrapping your global environment, run `/eagle-claude-md` inside any project to generate a project-specific CLAUDE.md. This sets up Claude Code to understand that project's stack, commands, and conventions — without duplicating global rules.

## Idempotent

Every step checks its own state before acting. Running twice produces the same result as running once.
