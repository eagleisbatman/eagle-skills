# Compact Hook

`compact.sh` is a PreToolUse hook that intercepts Bash commands before Claude executes them and rewrites verbose ones to compact equivalents. This saves context window tokens without losing information.

## What it rewrites

| Command | Rewritten to | Tokens saved |
|---------|-------------|-------------|
| `git status` | `git status -s` | ~10 lines of prose removed |
| `git log` | `git log --oneline -20` | Author, date, full message body removed |
| `ls` | `ls -1` | Permissions, owner, size, date removed |
| `ls -l` | `ls -1` | Same |
| `ls -la` | `ls -1` | Same |
| `ls -lah` | `ls -1` | Same |
| `ls -al` | `ls -1` | Same |

## What it does NOT rewrite

Commands where the full output matters are deliberately left alone:

- `git diff` — Claude needs the actual changes
- `cargo test` / `npm test` — Claude needs failure context
- `docker logs` — Claude needs error messages
- `ls -lh src/` — Claude asked for sizes (has extra args)
- `git log --oneline -5` — Already compact

## How it works

The hook is a Bash script at `~/.claude/hooks/compact.sh` wired as a PreToolUse hook in `~/.claude/settings.json`. When Claude is about to run a Bash command:

1. The hook reads the command from stdin (JSON with `tool_input.command`)
2. Checks if the exact command matches a known verbose pattern
3. If it matches, outputs a JSON response with `updatedInput` containing the rewritten command
4. If it doesn't match, outputs nothing (command runs as-is)

## Installation

Installed automatically by the [Eagle Bootstrap](../eagle-bootstrap/) skill (`/eagle-bootstrap`). To install manually:

```bash
mkdir -p ~/.claude/hooks
cp eagle-bootstrap/references/compact.sh ~/.claude/hooks/compact.sh
chmod +x ~/.claude/hooks/compact.sh
```

Then add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/compact.sh"
          }
        ]
      }
    ]
  }
}
```
