#!/usr/bin/env bash
# SessionStart hook: checks for promotable compact candidates.
# Outputs a note for Claude to spawn the auto-promoter agent.
set +e

CANDIDATES="$HOME/.claude/hooks/compact-candidates.json"

[ -f "$CANDIDATES" ] || exit 0

promotable=$(jq '[.[] | select(.count >= 2)] | length' "$CANDIDATES" 2>/dev/null) || exit 0

if [ "${promotable:-0}" -gt 0 ]; then
  echo "[COMPACT] $promotable candidate(s) ready for auto-promotion. Spawn eagle-compact-promoter agent in background to review and promote them into compact-rules.json."
fi
exit 0
