#!/usr/bin/env bash
# PreToolUse hook: compact Bash output for Claude Code.
# Conservative: only rewrites when NO information is lost.
set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0
cmd_trimmed=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
rewritten="$cmd_trimmed"

# SAFE rewrites (no semantic loss, just less noise):
case "$cmd_trimmed" in
  # git status -s is the designed-for-machines format. Same info, less prose.
  "git status")         rewritten="git status -s" ;;

  # --oneline drops author/date/prose. Keeps SHA + subject.
  # Only safe if Claude just needs to know "what commits happened".
  # If Claude needs full context, it will use git show.
  "git log")            rewritten="git log --oneline -20" ;;

  # ls -1 drops permissions/size/date. Keep this ONLY when Claude asked for
  # bare `ls` / `ls -l` / `ls -la`. If it wanted sizes, it used `-lh` etc.
  "ls"|"ls -l"|"ls -la"|"ls -lah"|"ls -al")
                        rewritten="ls -1" ;;
esac

# DELIBERATELY NOT INCLUDED (lossy, causes re-runs):
#   git diff        → git diff --stat      # loses actual changes
#   cargo test      → cargo test --quiet   # loses failure context
#   docker logs     → docker logs --tail   # loses older errors

if [ "$rewritten" != "$cmd_trimmed" ]; then
  jq -n --arg c "$rewritten" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "compact-rewrite",
      updatedInput: { command: $c }
    }
  }'
fi
