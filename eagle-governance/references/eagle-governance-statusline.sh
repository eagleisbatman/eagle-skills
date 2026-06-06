#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"

jq_value() {
  local expr="$1"
  jq -r "$expr" <<<"$input" 2>/dev/null || true
}

cwd="$(jq_value '.workspace.current_dir // .cwd // empty')"
[ -n "$cwd" ] || cwd="$(pwd)"

if root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"; then
  :
else
  root="$cwd"
fi

state_dir="$root/.eagle-governance"
state_file="$state_dir/context-state.json"
mkdir -p "$state_dir"

model="$(jq_value '.model.display_name // .model.id // .model // empty')"
pct="$(jq_value '.context_window.used_percentage // .contextWindow.usedPercentage // empty')"
turn_text=""

if command -v eagle-mem >/dev/null 2>&1; then
  turn_text="$(cd "$root" && EAGLE_MEM_DISABLE_HOOKS=1 eagle-mem statusline 2>/dev/null || true)"
fi

jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg root "$root" \
  --arg model "$model" \
  --arg pct "$pct" \
  --arg eagle_mem_status "$turn_text" '
  {
    updated_at: $ts,
    root: $root,
    model: $model,
    eagle_mem_status: $eagle_mem_status
  }
  + (
    if ($pct != "" and $pct != "null") then
      {context_window: {used_percentage: ($pct | tonumber? // $pct)}}
    else
      {}
    end
  )
' > "$state_file"

if [ -n "$turn_text" ]; then
  if [ -n "$pct" ] && [ "$pct" != "null" ]; then
    printf '%s | ctx %s%%\n' "$turn_text" "$pct"
  else
    printf '%s\n' "$turn_text"
  fi
elif [ -n "$pct" ] && [ "$pct" != "null" ]; then
  printf 'Eagle Governance | ctx %s%%\n' "$pct"
else
  printf 'Eagle Governance\n'
fi
