# Installation

## Quick install

```bash
npx eagle-skills install
```

This runs an interactive menu where you choose which skills and agents to install. Select individual items by number (e.g., `1,3,8`) or `a` for all.

To install for every supported agent surface:

```bash
npx eagle-skills install --target all
```

Supported targets:

1. `claude`: skills to `~/.claude/skills`, agents to `~/.claude/agents`
2. `codex`: skills to `~/.codex/skills`
3. `grok`: skills to `~/.grok/skills`, agents to the Claude-compatible agent directory Grok discovers
4. `antigravity`: skills to `~/.gemini/config/skills` and `~/.gemini/antigravity-ide/skills`

## Without npm

```bash
curl -fsSL https://raw.githubusercontent.com/eagleisbatman/eagle-skills/main/install.sh | bash
```

## How it works

The installer:

1. Clones the repo to `~/.eagle-skills/`
2. Symlinks selected skills to the selected target skill directories
3. Symlinks selected agents to agent directories for targets that support agent files

Because items are symlinked (not copied), running `eagle-skills update` pulls the latest code and your installed items update instantly.

## Managing your installation

```bash
npx eagle-skills update --target all      # Pull latest changes
npx eagle-skills status --target all      # Show installed items, check for updates
npx eagle-skills usage --target all       # Show how to use each installed item
npx eagle-skills uninstall --target all   # Remove symlinks and optionally the repo
```

## Project governance

After installing skills, add hook-based engineering governance to a project:

```bash
npx eagle-skills govern status --target all
npx eagle-skills govern apply --target all --mode warn --dry-run
npx eagle-skills govern apply --target all --mode warn
npx eagle-skills govern verify --target all
```

Claude Code and Codex get project-local hooks. Grok Build and Antigravity get advisory instruction shims in v1.

If Eagle Mem is installed, Governance automatically uses it as a durable partner:

- handoffs are mirrored into Eagle Mem task state
- pending feature verification appears in governance status and completion checks
- prior test/lint history can be surfaced when a compacted session resumes

If Eagle Eval is installed, the optional governance scenario pack is available at:

```text
eagle-governance/references/eagle-eval-governance-pack.json
```

## Manual install

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills

# Skills (symlink directories)
mkdir -p ~/.claude/skills ~/.codex/skills ~/.grok/skills ~/.gemini/config/skills ~/.gemini/antigravity-ide/skills
for skill in eagle-*/; do
  [ -f "$skill/SKILL.md" ] || continue
  ln -sf "$(pwd)/$skill" ~/.claude/skills/$(basename "$skill")
  ln -sf "$(pwd)/$skill" ~/.codex/skills/$(basename "$skill")
  ln -sf "$(pwd)/$skill" ~/.grok/skills/$(basename "$skill")
  ln -sf "$(pwd)/$skill" ~/.gemini/config/skills/$(basename "$skill")
  ln -sf "$(pwd)/$skill" ~/.gemini/antigravity-ide/skills/$(basename "$skill")
done

# Agents (symlink .md files)
mkdir -p ~/.claude/agents
for agent in agents/eagle-*.md; do
  ln -sf "$(pwd)/$agent" ~/.claude/agents/$(basename "$agent")
done
```

## Updating

```bash
# If installed via npx
npx eagle-skills update

# If installed manually
cd path/to/eagle-skills && git pull
```

Symlinked items point to the cloned repo, so `git pull` updates everything.

## Uninstalling

```bash
npx eagle-skills uninstall
```

This removes Eagle symlinks from the selected target directories and optionally deletes the cloned repo at `~/.eagle-skills/`.
