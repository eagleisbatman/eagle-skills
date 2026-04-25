## Eagle Skills

Skills and agents package for Claude Code — 11 skills + 12 agents (3 lifecycle + 9 review specialists).

## Stack

Bash (CLI installer), Markdown (SKILL.md files, agent definitions)

## Commands

| Command | What it does |
|---------|-------------|
| `bin/eagle-skills install` | Interactive installer — select skills/agents to symlink |
| `bin/eagle-skills update` | Pull latest and verify symlinks |
| `bin/eagle-skills status` | Show installed items, check for updates |
| `bin/eagle-skills usage` | Show how to use installed items |
| `bin/eagle-skills uninstall` | Remove symlinks and optionally the repo |

## Architecture

- Skills are directories with `SKILL.md` + optional `references/` — symlinked to `~/.claude/skills/`
- Agents are single `.md` files in `agents/` — symlinked to `~/.claude/agents/`
- CLI uses parallel arrays (SKILL_DIRS, SKILL_NAMES, SKILL_DESCS, etc.) — all arrays must stay in sync when adding skills
- `install.sh` is a thin wrapper that clones and runs `bin/eagle-skills install`
- Package is npm-publishable via `bin` field in package.json (npx eagle-skills)

## Conventions

- All skill directories and agent files use `eagle-` prefix
- SKILL.md frontmatter requires `name` and `description` fields — description is the trigger phrase list
- Agent .md files use Claude Code agent frontmatter (`name`, `description`, optional `model`)
- Version bumps touch both `package.json` and the `VERSION` variable in `bin/eagle-skills`
