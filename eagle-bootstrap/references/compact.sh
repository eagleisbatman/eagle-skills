#!/usr/bin/env bash
# PreToolUse hook: compact Bash output for Claude Code.
# Reads rewrite rules from compact-rules.json — add entries there, not here.
set -euo pipefail

HOOKS_DIR="$HOME/.claude/hooks"
RULES="$HOOKS_DIR/compact-rules.json"
FILTER="$HOOKS_DIR/compact-filter.sh"

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0
cmd_trimmed=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

[ ! -f "$RULES" ] && exit 0

match=$(jq -r --arg cmd "$cmd_trimmed" '
  .[] | (.pattern as $p |
    if ($cmd | test($p)) then
      if .type == "flag" then .rewrite
      elif .type == "pipe" then "PIPE:" + .filter
      else empty end
    else empty end)
' "$RULES" | head -1)

[ -z "$match" ] && exit 0

if [[ "$match" == PIPE:* ]]; then
  # Skip pipe-through for compound commands — shell precedence would break the pipe
  [[ "$cmd_trimmed" =~ ['\&\&'\|'||'';''|''>''<''`''\$\('] ]] && exit 0
  filter_name="${match#PIPE:}"
  if [ -x "$FILTER" ]; then
    rewritten="set -o pipefail; { $cmd_trimmed ; } 2>&1 | \"$FILTER\" $filter_name"
  else
    exit 0
  fi
else
  rewritten="$match"
fi

jq -n --arg c "$rewritten" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    permissionDecisionReason: "compact-rewrite",
    updatedInput: { command: $c }
  }
}'
