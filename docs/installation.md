# Installation

## Quick install

```bash
npx eagle-skills install
```

This runs an interactive menu where you choose which skills and agents to install. Select individual items by number (e.g., `1,3,8`) or `a` for all.

## Without npm

```bash
curl -fsSL https://raw.githubusercontent.com/eagleisbatman/eagle-skills/main/install.sh | bash
```

## How it works

The installer:

1. Clones the repo to `~/.eagle-skills/`
2. Symlinks selected skills to `~/.claude/skills/<name>/`
3. Symlinks selected agents to `~/.claude/agents/<name>.md`

Because items are symlinked (not copied), running `eagle-skills update` pulls the latest code and your installed items update instantly.

## Managing your installation

```bash
npx eagle-skills update      # Pull latest changes
npx eagle-skills status      # Show installed items, check for updates
npx eagle-skills usage       # Show how to use each installed item
npx eagle-skills uninstall   # Remove symlinks and optionally the repo
```

## Manual install

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills

# Skills (symlink directories)
for skill in eagle-*/; do
  [ -f "$skill/SKILL.md" ] || continue
  ln -sf "$(pwd)/$skill" ~/.claude/skills/$(basename "$skill")
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

This removes all symlinks from `~/.claude/skills/` and `~/.claude/agents/` and optionally deletes the cloned repo at `~/.eagle-skills/`.
