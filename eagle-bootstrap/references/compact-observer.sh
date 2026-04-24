#!/usr/bin/env bash
# PostToolUse hook: logs uncovered verbose Bash commands as candidates
# for new compact-rules.json entries. Run /eagle-compact-add to review.
set +e

HOOKS_DIR="$HOME/.claude/hooks"
RULES="$HOOKS_DIR/compact-rules.json"
CANDIDATES="$HOOKS_DIR/compact-candidates.json"
THRESHOLD=30

input=$(cat)

eval "$(echo "$input" | jq -r '
  "cmd=" + (.tool_input.command // "" | @sh),
  "stdout_n=" + ((.tool_response.stdout // "" | split("\n") | length) | tostring),
  "stderr_n=" + ((.tool_response.stderr // "" | split("\n") | length) | tostring)
' 2>/dev/null)" || exit 0

[ -z "$cmd" ] && exit 0
total=$((stdout_n + stderr_n))

[ "$total" -lt "$THRESHOLD" ] && exit 0
[[ "$cmd" == *"compact-filter.sh"* ]] && exit 0

cmd_trimmed=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [[ "$cmd_trimmed" == *'&&'* || "$cmd_trimmed" == *'||'* || \
      "$cmd_trimmed" == *';'* || "$cmd_trimmed" == *'|'* || \
      "$cmd_trimmed" == *'>'* || "$cmd_trimmed" == *'<'* || \
      "$cmd_trimmed" == *'$('* || "$cmd_trimmed" == *\`* ]]; then
  exit 0
fi

[ -f "$RULES" ] && {
  covered=$(jq --arg cmd "$cmd_trimmed" \
    '[.[] | select($cmd | test(.pattern))] | length' "$RULES" 2>/dev/null)
  [ "${covered:-0}" -gt 0 ] && exit 0
}

read -r first second _ <<< "$cmd_trimmed"
case "$first" in
  git|docker|npm|npx|pnpm|yarn|cargo|pip|pip3|kubectl|helm|terraform|go|python|python3|ruby|swift|dotnet|mix)
    key="${first}${second:+ $second}" ;;
  *)
    key="$first" ;;
esac

[ -f "$CANDIDATES" ] || echo '[]' > "$CANDIDATES" 2>/dev/null
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

lockdir="$CANDIDATES.lock"
mkdir "$lockdir" 2>/dev/null || exit 0
trap 'rmdir "$lockdir" 2>/dev/null' EXIT

existing=$(cat "$CANDIDATES" 2>/dev/null) || existing='[]'

has_key=$(echo "$existing" | jq --arg key "$key" \
  '[.[] | select(.key == $key)] | length' 2>/dev/null) || has_key=0

if [ "$has_key" -gt 0 ]; then
  updated=$(echo "$existing" | jq --arg key "$key" --arg cmd "$cmd_trimmed" \
    --argjson lines "$total" --arg now "$now" '
    map(if .key == $key then
      .count += 1 | .last_seen = $now |
      if $lines > .sample_lines then .sample_cmd = $cmd | .sample_lines = $lines
      else . end
    else . end)
  ' 2>/dev/null) || exit 0
else
  updated=$(echo "$existing" | jq --arg key "$key" --arg cmd "$cmd_trimmed" \
    --argjson lines "$total" --arg now "$now" '
    . + [{key: $key, count: 1, sample_cmd: $cmd, sample_lines: $lines, last_seen: $now}]
  ' 2>/dev/null) || exit 0
fi

echo "$updated" > "$CANDIDATES.tmp" 2>/dev/null && mv "$CANDIDATES.tmp" "$CANDIDATES" 2>/dev/null
exit 0
