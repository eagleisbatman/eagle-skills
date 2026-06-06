#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"

jq_value() {
  local expr="$1"
  jq -r "$expr" <<<"$input" 2>/dev/null || true
}

provider="${EAGLE_GOVERNANCE_PROVIDER:-}"
if [ -z "$provider" ] && jq -e 'has("toolCall") or has("workspacePaths") or has("transcriptPath")' <<<"$input" >/dev/null 2>&1; then
  provider="antigravity"
fi
[ -n "$provider" ] || provider="default"

event="$(jq_value '.hook_event_name // .hookEventName // empty')"
[ -n "$event" ] || event="${EAGLE_GOVERNANCE_EVENT:-${GROK_HOOK_EVENT:-}}"

cwd="$(jq_value '.cwd // .toolCall.args.Cwd // .workspacePaths[0] // empty')"
[ -n "$cwd" ] || cwd="$(pwd)"

if root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"; then
  :
else
  root="$cwd"
fi

config="$root/.eagle-governance.json"
state_dir="$root/.eagle-governance"
state_file="$state_dir/state.json"
handoff_file="$state_dir/handoff.md"
restore_file="$state_dir/restore-receipt.md"

config_string() {
  local expr="$1"
  local fallback="$2"
  jq -r "$expr // \"$fallback\"" "$config" 2>/dev/null || printf '%s\n' "$fallback"
}

config_bool() {
  local expr="$1"
  local fallback="$2"
  jq -r "$expr // $fallback" "$config" 2>/dev/null || printf '%s\n' "$fallback"
}

config_num() {
  local expr="$1"
  local fallback="$2"
  jq -r "$expr // $fallback" "$config" 2>/dev/null || printf '%s\n' "$fallback"
}

mode="$(config_string '.mode' 'warn')"

gate_enabled() {
  local key="$1"
  config_bool ".gates.$key" "true"
}

eagle_mem_enabled() {
  local enabled
  enabled="$(config_string '.eagle_mem.enabled' 'auto')"
  case "$enabled" in
    false|off|0) return 1 ;;
    true|on|1|auto) command -v eagle-mem >/dev/null 2>&1 ;;
    *) command -v eagle-mem >/dev/null 2>&1 ;;
  esac
}

eagle_mem_setting_enabled() {
  local key="$1"
  local fallback="$2"
  [ "$(config_bool ".eagle_mem.$key" "$fallback")" = "true" ]
}

should_block_warning() {
  case "$mode" in
    strict|block|block-risky) return 0 ;;
    *) return 1 ;;
  esac
}

json_context() {
  local message="$1"
  if [ "$provider" = "antigravity" ]; then
    case "$event" in
      PreInvocation|PostInvocation)
        jq -n --arg message "$message" '{injectSteps: [{ephemeralMessage: $message}]}'
        ;;
      PreToolUse|PermissionRequest)
        jq -n --arg reason "$message" '{decision: "force_ask", reason: $reason}'
        ;;
      Stop|TaskCompleted|SubagentStop)
        jq -n --arg reason "$message" '{decision: "", reason: $reason}'
        ;;
      *)
        jq -n '{}'
        ;;
    esac
    return
  fi
  jq -n --arg event "$event" --arg message "$message" '{
    hookSpecificOutput: {
      hookEventName: $event,
      additionalContext: $message
    }
  }'
}

json_block() {
  local reason="$1"
  if [ "$provider" = "antigravity" ]; then
    case "$event" in
      PreToolUse|PermissionRequest)
        jq -n --arg reason "$reason" '{decision: "deny", reason: $reason}'
        ;;
      Stop|TaskCompleted|SubagentStop)
        jq -n --arg reason "$reason" '{decision: "continue", reason: $reason}'
        ;;
      PostInvocation)
        jq -n --arg reason "$reason" '{injectSteps: [{ephemeralMessage: $reason}], terminationBehavior: "force_continue"}'
        ;;
      *)
        jq -n --arg reason "$reason" '{decision: "deny", reason: $reason}'
        ;;
    esac
    return
  fi
  if [ "$event" = "PreToolUse" ]; then
    jq -n --arg event "$event" --arg reason "$reason" '{
      decision: "block",
      reason: $reason,
      hookSpecificOutput: {
        hookEventName: $event,
        permissionDecision: "deny",
        permissionDecisionReason: $reason,
        additionalContext: $reason
      }
    }'
  else
    jq -n --arg event "$event" --arg reason "$reason" '{
      decision: "block",
      reason: $reason,
      hookSpecificOutput: {
        hookEventName: $event,
        additionalContext: $reason
      }
    }'
  fi
}

ensure_state_dir() {
  mkdir -p "$state_dir"
}

changed_files_count() {
  git -C "$root" status --porcelain --untracked-files=all 2>/dev/null | wc -l | tr -d ' '
}

changed_files_list() {
  git -C "$root" status --porcelain --untracked-files=all 2>/dev/null | sed -n '1,40p'
}

diff_line_count() {
  git -C "$root" diff --numstat 2>/dev/null | awk '{ add += $1; del += $2 } END { print add + del + 0 }'
}

write_state_test_run() {
  ensure_state_dir
  jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg root "$root" '{
    last_test_at: $ts,
    root: $root
  }' > "$state_file"
}

state_has_test_run() {
  [ -f "$state_file" ] && jq -e '.last_test_at' "$state_file" >/dev/null 2>&1
}

write_handoff() {
  ensure_state_dir
  {
    printf '# Eagle Governance Handoff\n\n'
    printf 'Generated: %s\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'Project: %s\n\n' "$root"
    printf 'Event: %s\n\n' "${event:-unknown}"
    printf '## Changed Files\n\n'
    changed_files_list || true
    printf '\n## Guidance\n\n'
    printf -- '- Start a fresh agent session or compact-resume before further implementation.\n'
    printf -- '- Read this handoff, then inspect the current git diff before editing.\n'
    printf -- '- Keep AGENTS.md / CLAUDE.md as routing shims; governance is enforced by hooks.\n'
  } > "$handoff_file"
  mirror_handoff_to_eagle_mem
}

write_restore_receipt() {
  ensure_state_dir
  local trigger compact_summary
  trigger="$(jq_value '.trigger // empty')"
  compact_summary="$(jq_value '.compact_summary // .compactSummary // empty')"
  {
    printf '# Eagle Governance Restore Receipt\n\n'
    printf 'Generated: %s\n\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'Project: %s\n\n' "$root"
    printf 'Event: %s\n\n' "${event:-unknown}"
    [ -n "$trigger" ] && printf 'Trigger: %s\n\n' "$trigger"
    if [ -n "$compact_summary" ]; then
      printf '## Compact Summary\n\n'
      printf '%s\n\n' "$compact_summary" | sed -n '1,80p'
    fi
    printf '## Restore Guidance\n\n'
    printf -- '- Load .eagle-governance/handoff.md if it exists.\n'
    printf -- '- Inspect the current git diff before editing.\n'
    printf -- '- Continue with one scoped task and keep context small.\n'
  } > "$restore_file"
}

mirror_handoff_to_eagle_mem() {
  eagle_mem_setting_enabled "handoff_mirror" "true" || return 0
  eagle_mem_enabled || return 0

  local fingerprint stamp_file desc
  stamp_file="$state_dir/handoff.mirrored"
  fingerprint="$(printf '%s|%s|%s|%s' "${event:-unknown}" "$(changed_files_count)" "$(diff_line_count)" "$(wc -c < "$handoff_file" 2>/dev/null || printf 0)" | shasum -a 256 | awk '{print $1}')"
  if [ -f "$stamp_file" ] && [ "$(cat "$stamp_file" 2>/dev/null)" = "$fingerprint" ]; then
    return 0
  fi

  desc="Eagle Governance forced a context handoff.
Project: $root
Event: ${event:-unknown}
Handoff file: $handoff_file
Changed files: $(changed_files_count)
Diff lines: $(diff_line_count)
Next step: start a fresh session or compact-resume, read the handoff, inspect git diff, then continue one task at a time."

  if (cd "$root" && EAGLE_MEM_DISABLE_HOOKS=1 eagle-mem tasks add "Eagle Governance handoff" --agent eagle-governance --desc "$desc" >/dev/null 2>&1); then
    printf '%s\n' "$fingerprint" > "$stamp_file"
  fi
}

context_risk() {
  local transcript_path size warn_bytes handoff_bytes max_changed changed
  transcript_path="$(jq_value '.transcript_path // .transcriptPath // empty')"
  warn_bytes="$(config_num '.context_budget.warn_bytes' 500000)"
  handoff_bytes="$(config_num '.context_budget.handoff_bytes' 900000)"
  max_changed="$(config_num '.context_budget.max_changed_files' 25)"
  changed="$(changed_files_count)"

  if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    size="$(wc -c < "$transcript_path" | tr -d ' ')"
  else
    size=0
  fi

  if [ "$size" -ge "$handoff_bytes" ] || [ "$changed" -ge "$max_changed" ]; then
    printf 'handoff:%s:%s\n' "$size" "$changed"
  elif [ "$size" -ge "$warn_bytes" ]; then
    printf 'warn:%s:%s\n' "$size" "$changed"
  else
    printf 'ok:%s:%s\n' "$size" "$changed"
  fi
}

tool_text() {
  jq -r '
    .tool_input.command //
    .tool_input.file_path //
    .toolCall.args.CommandLine //
    .toolCall.args.TargetFile //
    .toolCall.args.TargetContent //
    .toolCall.args.ReplacementContent //
    (if (.tool_input? | type) == "object" then (.tool_input | to_entries | map(.value | tostring) | join(" ")) else empty end) //
    (if (.toolCall.args? | type) == "object" then (.toolCall.args | to_entries | map(.value | tostring) | join(" ")) else empty end) //
    ""
  ' <<<"$input" 2>/dev/null || true
}

is_write_like_tool_or_command() {
  local text="$1"
  local tool_name
  tool_name="$(jq_value '.tool_name // .toolCall.name // empty')"
  [[ "$tool_name" =~ ^(Edit|Write|apply_patch|write_to_file|replace_file_content|multi_replace_file_content)$ ]] && return 0
  [[ "$text" =~ (^|[[:space:];])(cp|mv|rm|mkdir|touch|tee|chmod|chown|cat[[:space:]].*[>]|printf[[:space:]].*[>]|echo[[:space:]].*[>])([[:space:]]|$) ]] && return 0
  [[ "$text" =~ [\>\<] ]] && return 0
  return 1
}

is_test_command() {
  local cmd="$1"
  [[ "$cmd" =~ (^|[[:space:];])((npm|pnpm|yarn|bun)[[:space:]]+(test|run[[:space:]]+test|run[[:space:]]+lint|run[[:space:]]+typecheck)|pytest|cargo[[:space:]]+test|go[[:space:]]+test|make[[:space:]]+(test|lint|check))($|[[:space:];]) ]]
}

has_destructive_command() {
  local cmd="$1"
  [[ "$cmd" =~ (^|[[:space:];])(rm[[:space:]]+-rf[[:space:]]+(/|~|\$HOME|\*)|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f|chmod[[:space:]]+-R[[:space:]]+777|chown[[:space:]]+-R) ]]
}

has_secret_write() {
  local text="$1"
  [[ "$text" =~ (^|/)(\.env|id_rsa|id_dsa|id_ed25519|.*\.pem|.*\.key)($|[^[:alnum:]_-]) ]]
}

contains_outside_root_path() {
  local text="$1"
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    case "$path" in
      "$root"|"$root"/*|/dev/null)
        ;;
      *)
        return 0
        ;;
    esac
  done < <(printf '%s\n' "$text" | grep -Eo '/[^[:space:];|&><`"'"'"']+' || true)
  return 1
}

has_outside_root_write() {
  local cmd="$1"
  local tool_name
  tool_name="$(jq_value '.tool_name // empty')"
  if [[ "$tool_name" =~ ^(Edit|Write|apply_patch)$ ]]; then
    contains_outside_root_path "$cmd"
    return
  fi

  [[ "$cmd" =~ (^|[[:space:];])(cp|mv|rm|mkdir|touch|tee|chmod|chown)[[:space:]] ]] || [[ "$cmd" =~ [\>\<] ]] || return 1
  contains_outside_root_path "$cmd"
}

warn_or_block() {
  local message="$1"
  if should_block_warning; then
    json_block "$message"
  else
    json_context "$message"
  fi
}

eagle_mem_pending_feature_count() {
  eagle_mem_setting_enabled "feature_pending_gate" "true" || return 0
  eagle_mem_enabled || return 0

  local output count
  output="$(cd "$root" && EAGLE_MEM_DISABLE_HOOKS=1 eagle-mem feature pending --limit 3 2>/dev/null || true)"
  if printf '%s\n' "$output" | grep -q "No pending feature verifications"; then
    printf '0\n'
    return 0
  fi
  count="$(printf '%s\n' "$output" | grep -Eo '[0-9]+ check' | awk 'NR == 1 { print $1 }')"
  [ -n "$count" ] && printf '%s\n' "$count"
}

eagle_mem_recent_test_hint() {
  eagle_mem_setting_enabled "test_history_lookup" "true" || return 1
  eagle_mem_enabled || return 1

  local output
  output="$(cd "$root" && EAGLE_MEM_DISABLE_HOOKS=1 eagle-mem search "test OR lint OR typecheck" --json --limit 1 2>/dev/null || true)"
  [ -n "$output" ] || return 1
  printf '%s\n' "$output" | jq -e '
    if type == "array" then length > 0
    elif type == "object" then ((.results // .sessions // .items // []) | length) > 0
    else false end
  ' >/dev/null 2>&1
}

restore_context_message() {
  local message=""
  if [ -f "$handoff_file" ]; then
    message="Eagle Governance restore receipt: read .eagle-governance/handoff.md before further implementation. "
  fi
  if [ -f "$restore_file" ]; then
    message="${message}A compact restore receipt exists at .eagle-governance/restore-receipt.md. "
  fi
  if [ -n "$message" ]; then
    printf '%s\n' "${message}Keep injected context small and verify git diff before editing."
  fi
}

handle_user_prompt_submit() {
  local prompt
  prompt="$(jq_value '.prompt // empty')"
  if [[ "$prompt" =~ (build|implement|create|add|ship).*(app|feature|system|module|workflow|runtime) ]]; then
    json_context "Eagle Governance: broad implementation detected. Keep scope explicit, inspect existing architecture first, and let hooks enforce policy gates."
  fi
}

handle_pre_tool_use() {
  local text
  text="$(tool_text)"

  if [ "$(gate_enabled destructive_commands)" = "true" ] && has_destructive_command "$text"; then
    json_block "Eagle Governance blocked a destructive command. Explain the need and request explicit human approval before retrying."
    return
  fi

  if is_write_like_tool_or_command "$text" && has_secret_write "$text"; then
    json_block "Eagle Governance blocked a likely secret-file write. Do not write secrets or private keys through agent tools."
    return
  fi

  if has_outside_root_write "$text"; then
    json_block "Eagle Governance blocked a write-like command targeting an absolute path outside the project root."
    return
  fi

  if [ "$(gate_enabled context_budget)" = "true" ] && is_write_like_tool_or_command "$text"; then
    local risk status size changed
    risk="$(context_risk)"
    status="${risk%%:*}"
    size="${risk#*:}"
    size="${size%%:*}"
    changed="${risk##*:}"
    if [ "$status" = "handoff" ]; then
      write_handoff
      json_block "Eagle Governance requires a fresh-session handoff before write-like tool use. Handoff written to .eagle-governance/handoff.md (transcript bytes: $size, changed files: $changed)."
      return
    fi
  fi

  if [ "$(gate_enabled dependency_change)" = "true" ] && [[ "$text" =~ (^|[[:space:];])(npm|pnpm|yarn|bun)[[:space:]]+(add|install|i)[[:space:]]+[^[:space:]-] ]]; then
    warn_or_block "Eagle Governance: dependency change detected. Justify why existing dependencies are insufficient and verify package impact."
  fi
}

handle_post_tool_use() {
  local text risk status size changed files_limit lines_limit files lines message
  text="$(tool_text)"
  if is_test_command "$text"; then
    write_state_test_run
  fi

  risk="$(context_risk)"
  status="${risk%%:*}"
  size="${risk#*:}"
  size="${size%%:*}"
  changed="${risk##*:}"

  if [ "$status" = "handoff" ] && [ "$(gate_enabled context_budget)" = "true" ]; then
    write_handoff
    if is_write_like_tool_or_command "$text"; then
      json_block "Eagle Governance requires a fresh-session handoff before further write-like implementation. Handoff written to .eagle-governance/handoff.md (transcript bytes: $size, changed files: $changed)."
    else
      json_context "Eagle Governance wrote a fresh-session handoff to .eagle-governance/handoff.md (transcript bytes: $size, changed files: $changed). Continue read-only triage if needed, but start fresh or compact-resume before implementation."
    fi
    return
  fi

  files="$(changed_files_count)"
  lines="$(diff_line_count)"
  files_limit="$(config_num '.diff_budget.files' 12)"
  lines_limit="$(config_num '.diff_budget.lines' 600)"
  message=""

  if [ "$(gate_enabled db_change)" = "true" ] && git -C "$root" status --porcelain --untracked-files=all 2>/dev/null | grep -E '(migration|migrations|schema|prisma|drizzle|sequelize|typeorm)' >/dev/null; then
    message="${message}Eagle Governance: database/schema files changed; run database/data-integrity review. "
  fi

  if [ "$(gate_enabled dependency_change)" = "true" ] && git -C "$root" status --porcelain --untracked-files=all 2>/dev/null | grep -E '(package\.json|pnpm-lock\.yaml|package-lock\.json|yarn\.lock|bun\.lockb|Cargo\.toml|go\.mod|pyproject\.toml|requirements\.txt)' >/dev/null; then
    message="${message}Eagle Governance: dependency manifest changed; justify and verify dependency impact. "
  fi

  if [ "$(gate_enabled diff_budget)" = "true" ] && { [ "$files" -gt "$files_limit" ] || [ "$lines" -gt "$lines_limit" ]; }; then
    message="${message}Eagle Governance: diff budget exceeded (${files} files, ${lines} lines); pause and justify scope. "
  fi

  if [ -n "$message" ]; then
    warn_or_block "$message"
  fi
}

handle_stop() {
  local risk status size changed message pending_features
  risk="$(context_risk)"
  status="${risk%%:*}"
  size="${risk#*:}"
  size="${size%%:*}"
  changed="${risk##*:}"

  if [ "$status" = "handoff" ] && [ "$(gate_enabled context_budget)" = "true" ]; then
    write_handoff
    json_block "Eagle Governance requires a fresh-session handoff before completion. Handoff written to .eagle-governance/handoff.md (transcript bytes: $size, changed files: $changed)."
    return
  fi

  message=""

  pending_features="$(eagle_mem_pending_feature_count)"
  if [ "${pending_features:-0}" -gt 0 ] 2>/dev/null; then
    message="${message}Eagle Governance: Eagle Mem reports ${pending_features} pending feature verification(s); verify or waive before release. "
  fi

  if [ "$(gate_enabled tests_required)" = "true" ] && [ "$(changed_files_count)" -gt 0 ] && ! state_has_test_run; then
    if eagle_mem_recent_test_hint; then
      message="${message}Eagle Governance: changed files detected; no local test/lint marker was observed in this governed session, although Eagle Mem has prior test/lint history. Confirm it covers the current diff. "
    else
      message="${message}Eagle Governance: changed files detected but no test/lint command was observed in this governed session. "
    fi
  fi

  if [ -n "$message" ]; then
    warn_or_block "$message"
  fi
}

handle_compact_restore() {
  local message
  message="$(restore_context_message)"
  if [ -n "$message" ]; then
    json_context "$message"
  fi
}

handle_pre_invocation() {
  local risk status size changed message
  risk="$(context_risk)"
  status="${risk%%:*}"
  size="${risk#*:}"
  size="${size%%:*}"
  changed="${risk##*:}"
  if [ "$status" = "handoff" ] && [ "$(gate_enabled context_budget)" = "true" ]; then
    write_handoff
    json_context "Eagle Governance context risk is high (transcript bytes: $size, changed files: $changed). Continue read-only triage only; start a fresh agent conversation before implementation."
    return
  fi
  message="$(restore_context_message)"
  if [ -n "$message" ]; then
    json_context "$message"
  fi
}

case "$event" in
  UserPromptSubmit)
    handle_user_prompt_submit
    ;;
  PreToolUse|PermissionRequest)
    handle_pre_tool_use
    ;;
  PostToolUse)
    handle_post_tool_use
    ;;
  Stop|TaskCompleted|SubagentStop)
    handle_stop
    ;;
  PreCompact)
    write_handoff
    ;;
  PostCompact)
    write_restore_receipt
    ;;
  PreInvocation|PostInvocation)
    handle_pre_invocation
    ;;
  SessionStart)
    source_value="$(jq_value '.source // empty')"
    if [[ "$source_value" =~ ^(startup|resume|compact)$ ]]; then
      handle_compact_restore
    fi
    ;;
esac
