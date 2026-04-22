---
name: eagle-claude-md
description: >
  Full project onboarding: generates a lean CLAUDE.md, bootstraps LLM Wiki, links Obsidian vault,
  and installs eagle-skills (9 skills + 14 agents). Use when starting a new project, onboarding to
  a codebase, or when the user says: 'init claude', 'setup claude md', 'create claude.md',
  'project init', 'eagle init', 'bootstrap this project', 'set up this repo for claude',
  'add claude.md', 'onboard this project', 'install eagle skills'. Also trigger when you detect
  a project has no CLAUDE.md and the user is about to do significant work in it.
---

# Eagle CLAUDE.md

Full project onboarding: generate a minimal project-specific CLAUDE.md, bootstrap LLM Wiki, link Obsidian vault, and install eagle-skills. The CLAUDE.md contains ONLY what is unique to this project — no duplication of global rules.

## Core Constraint

**Before writing any section, check the global `~/.claude/CLAUDE.md`.** If the rule or information already exists there, do NOT include it in the project file. A project CLAUDE.md that restates global rules is bloat, not documentation.

A good project CLAUDE.md for a typical repo is **under 50 lines**. If yours is longer, you're duplicating global concerns.

## What belongs in a project CLAUDE.md

Only these categories. Nothing else.

1. **Project identity** — name, one-line purpose, primary stack
2. **Repo commands** — test, lint, build, dev server, deploy. Only commands specific to THIS repo.
3. **Architecture invariants** — decisions that would surprise a new reader. "API routes are in `src/routes/`, not `src/api/`". "We use Drizzle, not Prisma, despite the Prisma config file being present (legacy)."
4. **Domain vocabulary** — terms that have project-specific meaning. "A 'campaign' is always a marketing campaign, never an ad campaign."
5. **Active constraints** — platform targets, performance budgets, deadlines, compatibility requirements specific to this project.
6. **Project-specific conventions** — naming patterns, file organization rules, or code style that differs from global defaults.

## What does NOT belong

- Deployment workflow (global)
- LLM Wiki rules and page format (global)
- Design system references (global)
- Spectral agent list or usage (global)
- Railway configuration patterns (global)
- Anti-slop rules (global)
- Generic coding best practices
- Anything that applies to ALL your projects

## Process

Follow these steps in order. Each step has a detection check — if already done, skip it.

### Step 1: Analyze the project

Read the project root to understand the stack:

```
- package.json / Cargo.toml / pyproject.toml / Package.swift → stack + commands
- Directory structure (src/, app/, lib/, etc.) → architecture
- Existing CLAUDE.md → sections already written (preserve them)
- .env.example → environment variables the project needs
- README.md → project purpose and setup
```

If there is NO code yet (empty repo or brand-new scaffold), ask the user what they're building and generate a minimal starter CLAUDE.md with just project identity and planned stack.

### Step 2: Check global CLAUDE.md

Read `~/.claude/CLAUDE.md`. Extract all H2 headings. These are the topics you MUST NOT duplicate. If a project concern overlaps with a global section, reference it don't restate it.

### Step 3: Bootstrap LLM Wiki directories

**Detection:** Check if `raw/` and `wiki/` directories exist.

If missing, create the full structure:

```
raw/                          # Immutable source documents
wiki/
  index.md                    # Master index of all wiki pages
  log.md                      # Change log for wiki operations
  summaries/                  # Source document summaries
  concepts/                   # Concept pages
  entities/                   # Entity pages
  syntheses/                  # Cross-source synthesis pages
```

Write starter `wiki/index.md`:

```markdown
---
title: "Wiki Index"
type: index
created: <today>
updated: <today>
---

# <Project Name> Wiki

Knowledge base for <project-name>. Pages are organized by type:

- **Summaries** — key points from source documents in `raw/`
- **Concepts** — definitions, patterns, and techniques
- **Entities** — people, tools, services, and systems
- **Syntheses** — cross-cutting analysis and comparisons

## Pages

_No pages yet. Use `ingest raw/<file>` to create summaries from source documents._
```

Write starter `wiki/log.md`:

```markdown
---
title: "Wiki Log"
type: log
created: <today>
updated: <today>
---

# Wiki Change Log

| Date | Action | Page | Notes |
|------|--------|------|-------|
| <today> | init | — | Wiki structure created by eagle-claude-md |
```

### Step 4: Obsidian vault integration

**Detection:** Check if the symlink already exists in the vault.

The vault is the observer — the symlink lives IN the vault, pointing TO the project's wiki directory. This keeps the git repo clean (no vault-specific paths committed).

1. **Find the vault.** Check in order:
   - Read `~/.claude/eagle-config.json` for a saved `vaultPath`
   - Probe `~/eaglevault/`
   - Probe `~/Documents/Eagle Vault/`
   - Probe `~/Obsidian/Eagle Vault/`
   - If not found, ask the user for their vault path

2. **Save the vault path** to `~/.claude/eagle-config.json` so future runs don't re-prompt:
   ```json
   { "obsidianVaultPath": "/Users/<user>/eaglevault" }
   ```

3. **Create the symlink:**
   ```bash
   mkdir -p "<vault-path>/projects"
   ln -sfn "<absolute-project-path>/wiki" "<vault-path>/projects/<project-name>"
   ```

4. **Verify** the symlink resolves: `ls "<vault-path>/projects/<project-name>/index.md"`

If Obsidian is not installed (`/Applications/Obsidian.app` missing), skip this step and note it in the output. Don't install Obsidian — just inform the user.

### Step 5: Generate project CLAUDE.md

**If CLAUDE.md exists:** Read it, identify sections by H2 heading, merge — only add sections that are missing. Never overwrite existing sections. Leave user-written content untouched.

**If CLAUDE.md does not exist:** Generate a new one.

Structure:

```markdown
## <Project Name>

<one-line purpose>

## Stack

<primary tech: language, framework, database, hosting>

## Commands

| Command | What it does |
|---------|-------------|
| `<test>` | Run tests |
| `<lint>` | Run linter |
| `<build>` | Build for production |
| `<dev>` | Start dev server |

## Architecture

<2-5 bullet points about non-obvious structural decisions>

## Conventions

<only if there are project-specific patterns worth noting>
```

The output should feel like something a senior engineer writes in 5 minutes when handing off a repo — not a generated document.

### Step 6: Install eagle-skills

**Detection:** Check if eagle-skills are already installed:
- Skills: `ls ~/.claude/skills/eagle-*/SKILL.md 2>/dev/null | wc -l`
- Agents: `ls ~/.claude/agents/eagle-*.md 2>/dev/null | wc -l`

Expected: 9 skills, 14 agents.

**If missing or incomplete:**

1. Check if the repo is already cloned:
   ```bash
   ls ~/.eagle-skills/.git 2>/dev/null
   ```

2. If not cloned, clone it:
   ```bash
   git clone --quiet https://github.com/eagleisbatman/eagle-skills.git ~/.eagle-skills
   ```

3. If already cloned, pull latest:
   ```bash
   git -C ~/.eagle-skills pull --quiet
   ```

4. Symlink all skills (directories):
   ```bash
   mkdir -p ~/.claude/skills
   for skill in ~/.eagle-skills/eagle-*/; do
     name=$(basename "$skill")
     [ -f "$skill/SKILL.md" ] || continue
     ln -sfn "$skill" ~/.claude/skills/"$name"
   done
   ```

5. Symlink all agents (.md files):
   ```bash
   mkdir -p ~/.claude/agents
   for agent in ~/.eagle-skills/agents/eagle-*.md; do
     ln -sfn "$agent" ~/.claude/agents/$(basename "$agent")
   done
   ```

6. Verify counts match expected (9 skills, 14 agents).

**If already fully installed:** Skip and report counts.

### Step 7: Report

After all steps, print a short summary:

```
eagle-claude-md complete:
  CLAUDE.md:     <created | updated | already up to date>
  LLM Wiki:      <created | already exists>
  Obsidian:      <linked to <vault>/projects/<name> | skipped (no vault) | already linked>
  Eagle Skills:  <9/9 skills, 14/14 agents | installed | already installed>
```

## Idempotency

This skill is safe to run multiple times. Each step checks its own state before acting:

- Wiki dirs exist → skip creation
- Symlink exists and points correctly → skip linking
- CLAUDE.md section exists → skip that section
- Vault path saved → skip prompting
- Eagle-skills fully installed (9 skills + 14 agents) → skip installation

Re-running after project changes should only add new sections to CLAUDE.md if the project has evolved.
