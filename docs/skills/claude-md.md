# Eagle CLAUDE.md

Lean project-specific CLAUDE.md generator with LLM Wiki and Obsidian vault integration.

## What it does

Generates a CLAUDE.md that contains ONLY what is unique to the current project — no duplication of global rules. Also bootstraps the [LLM Wiki](https://github.com/tonbistudio/llm-wiki) directory structure and symlinks the wiki into your Obsidian vault.

## Command

```
/eagle-claude-md
```

Also triggers on: "init claude", "setup claude md", "create claude.md", "project init", "eagle init", "onboard this project"

## Process

1. Analyzes the project (stack, commands, architecture from config files)
2. Reads global `~/.claude/CLAUDE.md` to avoid duplicating existing sections
3. Creates `raw/` and `wiki/` directories with index and log files
4. Symlinks `wiki/` into your Obsidian vault (`<vault>/projects/<project-name>/`)
5. Generates a lean CLAUDE.md (typically under 50 lines)
6. Installs eagle-skills if not already present (11 skills + 12 agents)

## What belongs in a project CLAUDE.md

- Project identity (name, purpose, stack)
- Repo commands (test, lint, build, dev)
- Architecture invariants (surprising structural decisions)
- Domain vocabulary (project-specific terms)
- Active constraints (platform targets, budgets, deadlines)
- Project-specific conventions

## What does NOT belong

Anything that applies to all projects — deployment workflow, coding principles, Spectral agent list, Railway config, anti-slop rules. Those go in the global `~/.claude/CLAUDE.md`.

## Example

```
You: Set up this project for Claude
Claude: [reads package.json, checks global CLAUDE.md, creates wiki dirs,
        symlinks to vault, generates lean project CLAUDE.md]
```

## Idempotent

Safe to re-run. Existing sections are preserved, wiki dirs are skipped if present, symlinks are skipped if correct.
