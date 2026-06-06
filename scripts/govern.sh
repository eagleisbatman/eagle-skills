#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${EAGLE_SKILLS_SOURCE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TARGET_SELECTION="${EAGLE_SKILLS_TARGETS:-${EAGLE_SKILLS_TARGET:-claude}}"
PROJECT_DIR="$(pwd)"
MODE="warn"
DRY_RUN=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

info() { echo -e "${BLUE}info${RESET}  $1"; }
ok() { echo -e "${GREEN}  ok${RESET}  $1"; }
warn() { echo -e "${YELLOW}warn${RESET}  $1"; }
err() { echo -e "${RED} err${RESET}  $1"; }

usage() {
  cat <<'USAGE'
Eagle Skills governance

Usage:
  eagle-skills govern status [--target claude|codex|grok|antigravity|all] [--project PATH]
  eagle-skills govern apply  [--target claude|codex|grok|antigravity|all] [--mode warn|block-risky|strict] [--project PATH] [--dry-run]
  eagle-skills govern verify [--target claude|codex|grok|antigravity|all] [--project PATH] [--dry-run]
  eagle-skills govern help

Defaults:
  mode: warn
  context control: force handoff at high risk
  full hooks: Claude Code and Codex
  partial advisory support: Grok Build and Antigravity
USAGE
}

normalize_targets() {
  local raw="${1:-claude}"
  local -a out=()
  IFS=',' read -ra requested <<<"$raw"
  for target in "${requested[@]}"; do
    target="$(echo "$target" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
    case "$target" in
      all) out+=("claude" "codex" "grok" "antigravity") ;;
      claude|claude-code) out+=("claude") ;;
      codex|openai-codex) out+=("codex") ;;
      grok|grok-build) out+=("grok") ;;
      antigravity|anti-gravity|google-antigravity) out+=("antigravity") ;;
      "") ;;
      *) err "Unknown target: $target"; exit 1 ;;
    esac
  done

  TARGETS=()
  local seen=" "
  for target in "${out[@]}"; do
    if [[ "$seen" != *" $target "* ]]; then
      TARGETS+=("$target")
      seen+="$target "
    fi
  done
  [ ${#TARGETS[@]} -gt 0 ] || TARGETS=("claude")
}

parse_common_args() {
  POSITIONAL=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --target|-t)
        TARGET_SELECTION="$2"
        shift 2
        ;;
      --target=*)
        TARGET_SELECTION="${1#--target=}"
        shift
        ;;
      --mode)
        MODE="$2"
        shift 2
        ;;
      --mode=*)
        MODE="${1#--mode=}"
        shift
        ;;
      --project)
        PROJECT_DIR="$2"
        shift 2
        ;;
      --project=*)
        PROJECT_DIR="${1#--project=}"
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
  done
  normalize_targets "$TARGET_SELECTION"
  PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
}

run_or_echo() {
  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${DIM}would:${RESET} $*"
  else
    "$@"
  fi
}

write_file() {
  local path="$1"
  local content="$2"
  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${DIM}would write:${RESET} $path"
  else
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" > "$path"
  fi
}

copy_hook() {
  local target_path="$1"
  local src="$SOURCE_DIR/eagle-governance/references/eagle-governance.sh"
  if [ ! -f "$src" ]; then
    err "Missing governance hook template: $src"
    exit 1
  fi
  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${DIM}would copy:${RESET} $src -> $target_path"
  else
    mkdir -p "$(dirname "$target_path")"
    cp "$src" "$target_path"
    chmod +x "$target_path"
  fi
}

default_policy_json() {
  cat <<'JSON'
{
  "mode": "warn",
  "gates": {
    "db_change": true,
    "dependency_change": true,
    "diff_budget": true,
    "tests_required": true,
    "context_budget": true,
    "destructive_commands": true
  },
  "diff_budget": {
    "files": 12,
    "lines": 600
  },
  "context_budget": {
    "warn_bytes": 500000,
    "handoff_bytes": 900000,
    "max_changed_files": 25
  },
  "eagle_mem": {
    "enabled": "auto",
    "handoff_mirror": true,
    "feature_pending_gate": true,
    "test_history_lookup": true
  },
  "eagle_eval": {
    "enabled": false,
    "governance_pack": true
  }
}
JSON
}

ensure_policy() {
  local path="$PROJECT_DIR/.eagle-governance.json"
  if [ -f "$path" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${DIM}would keep existing:${RESET} $path"
    fi
    return 0
  fi
  local content
  content="$(default_policy_json | jq --arg mode "$MODE" '.mode = $mode')"
  write_file "$path" "$content"
}

append_managed_block() {
  local path="$1"
  local title="$2"
  local marker_start="<!-- eagle-governance:start -->"
  local marker_end="<!-- eagle-governance:end -->"
  local block
  block="$marker_start
## Eagle Governance

Governance is enforced by hooks; do not duplicate the full policy here.

- Follow hook feedback before continuing.
- If \`.eagle-governance/handoff.md\` exists, load it before implementation.
- Keep this file as a small routing shim for $title.
$marker_end"

  if [ -f "$path" ] && grep -q "$marker_start" "$path"; then
    if [ "$DRY_RUN" = true ]; then
      echo -e "  ${DIM}would keep managed block:${RESET} $path"
    fi
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${DIM}would append managed block:${RESET} $path"
  else
    if [ -f "$path" ]; then
      printf '\n%s\n' "$block" >> "$path"
    else
      printf '%s\n' "$block" > "$path"
    fi
  fi
}

settings_contains_governance() {
  local file="$1"
  [ -f "$file" ] && grep -q "eagle-governance.sh" "$file"
}

merge_claude_settings() {
  local file="$PROJECT_DIR/.claude/settings.json"
  local cmd='"${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/hooks/eagle-governance.sh"'
  if settings_contains_governance "$file"; then
    [ "$DRY_RUN" = true ] && echo -e "  ${DIM}would keep Claude hook wiring:${RESET} $file"
    return 0
  fi
  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${DIM}would merge Claude hook wiring:${RESET} $file"
    return
  fi
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || printf '{}\n' > "$file"
  local tmp
  tmp="$(mktemp)"
  jq --arg cmd "$cmd" '
    .hooks = (.hooks // {}) |
    .hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) + [{"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance prompt gate"}]}]) |
    .hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{"matcher":"Bash|Edit|Write","hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance pre-tool gate"}]}]) |
    .hooks.PostToolUse = ((.hooks.PostToolUse // []) + [{"matcher":"Bash|Edit|Write","hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance post-tool gate"}]}]) |
    .hooks.Stop = ((.hooks.Stop // []) + [{"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance completion gate"}]}]) |
    .hooks.PreCompact = ((.hooks.PreCompact // []) + [{"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance handoff writer"}]}]) |
    .hooks.PostCompact = ((.hooks.PostCompact // []) + [{"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance restore receipt"}]}]) |
    .hooks.SessionStart = ((.hooks.SessionStart // []) + [{"matcher":"compact","hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance compact resume"}]}])
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

merge_codex_hooks() {
  local file="$PROJECT_DIR/.codex/hooks.json"
  local cmd='"$(git rev-parse --show-toplevel)/.codex/hooks/eagle-governance.sh"'
  local shell_matcher="Bash|exec_command|shell_command|unified_exec|apply_patch|Edit|Write"
  if settings_contains_governance "$file"; then
    [ "$DRY_RUN" = true ] && echo -e "  ${DIM}would keep Codex hook wiring:${RESET} $file"
    return 0
  fi
  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${DIM}would merge Codex hook wiring:${RESET} $file"
    return
  fi
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || printf '{"hooks":{}}\n' > "$file"
  local tmp
  tmp="$(mktemp)"
  jq --arg cmd "$cmd" --arg shell_matcher "$shell_matcher" '
    .hooks = (.hooks // {}) |
    .hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) + [{"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance prompt gate"}]}]) |
    .hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{"matcher":$shell_matcher,"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance pre-tool gate"}]}]) |
    .hooks.PostToolUse = ((.hooks.PostToolUse // []) + [{"matcher":$shell_matcher,"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance post-tool gate"}]}]) |
    .hooks.Stop = ((.hooks.Stop // []) + [{"hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance completion gate"}]}]) |
    .hooks.PreCompact = ((.hooks.PreCompact // []) + [{"matcher":"manual|auto","hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance handoff writer"}]}]) |
    .hooks.PostCompact = ((.hooks.PostCompact // []) + [{"matcher":"manual|auto","hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance restore receipt"}]}]) |
    .hooks.SessionStart = ((.hooks.SessionStart // []) + [{"matcher":"compact","hooks":[{"type":"command","command":$cmd,"statusMessage":"Eagle governance compact resume"}]}])
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

apply_target() {
  local target="$1"
  case "$target" in
    claude)
      copy_hook "$PROJECT_DIR/.claude/hooks/eagle-governance.sh"
      merge_claude_settings
      append_managed_block "$PROJECT_DIR/CLAUDE.md" "Claude Code"
      ok "Claude Code governance configured"
      ;;
    codex)
      copy_hook "$PROJECT_DIR/.codex/hooks/eagle-governance.sh"
      merge_codex_hooks
      append_managed_block "$PROJECT_DIR/AGENTS.md" "Codex and generic agents"
      ok "Codex governance configured"
      ;;
    grok)
      append_managed_block "$PROJECT_DIR/AGENTS.md" "Grok Build advisory support"
      warn "Grok Build hook enforcement is not configured in v1; advisory shim installed."
      ;;
    antigravity)
      append_managed_block "$PROJECT_DIR/AGENTS.md" "Antigravity advisory support"
      warn "Antigravity hook enforcement is not configured in v1; advisory shim installed."
      ;;
  esac
}

cmd_apply() {
  command -v jq >/dev/null || { err "jq is required for govern apply"; exit 1; }
  case "$MODE" in warn|block-risky|strict) ;; *) err "Unknown mode: $MODE"; exit 1 ;; esac
  info "Applying governance to $PROJECT_DIR (mode: $MODE)"
  ensure_policy
  for target in "${TARGETS[@]}"; do
    apply_target "$target"
  done
  if [ "$DRY_RUN" = true ]; then
    info "Dry run only; no files changed."
  fi
}

status_line() {
  local label="$1"
  local ok_text="$2"
  local missing_text="$3"
  local check_path="$4"
  if [ -e "$check_path" ]; then
    ok "$label: $ok_text"
  else
    warn "$label: $missing_text"
  fi
}

policy_value() {
  local expr="$1"
  local fallback="$2"
  local policy="$PROJECT_DIR/.eagle-governance.json"
  if [ -f "$policy" ] && command -v jq >/dev/null; then
    jq -r "$expr // \"$fallback\"" "$policy" 2>/dev/null || printf '%s\n' "$fallback"
  else
    printf '%s\n' "$fallback"
  fi
}

eagle_mem_pending_count() {
  local output
  output="$(cd "$PROJECT_DIR" && eagle-mem feature pending --limit 3 2>/dev/null || true)"
  if printf '%s\n' "$output" | grep -q "No pending feature verifications"; then
    printf '0\n'
    return 0
  fi
  printf '%s\n' "$output" | grep -Eo '[0-9]+ check' | awk 'NR == 1 { print $1 }'
}

status_eagle_mem_bridge() {
  local enabled
  enabled="$(policy_value '.eagle_mem.enabled' 'auto')"
  case "$enabled" in
    false|off|0)
      warn "Eagle Mem bridge: disabled by policy"
      return
      ;;
  esac

  if ! command -v eagle-mem >/dev/null; then
    warn "Eagle Mem bridge: unavailable (install eagle-mem for durable recall and release verification)"
    return
  fi

  ok "Eagle Mem bridge: available"
  if [ "$(policy_value '.eagle_mem.handoff_mirror' 'true')" = "true" ]; then
    ok "Eagle Mem handoff mirror: enabled"
  else
    warn "Eagle Mem handoff mirror: disabled"
  fi

  if [ "$(policy_value '.eagle_mem.feature_pending_gate' 'true')" = "true" ]; then
    local pending
    pending="$(eagle_mem_pending_count)"
    if [ "${pending:-0}" -gt 0 ] 2>/dev/null; then
      warn "Eagle Mem feature verification: $pending pending"
    else
      ok "Eagle Mem feature verification: none pending"
    fi
  fi
}

status_eagle_eval_pack() {
  local pack="$SOURCE_DIR/eagle-governance/references/eagle-eval-governance-pack.json"
  if [ -f "$pack" ]; then
    ok "Eagle Eval governance pack: available"
  else
    warn "Eagle Eval governance pack: missing"
  fi

  if command -v eagle-eval >/dev/null; then
    ok "Eagle Eval CLI: available"
  elif [ "$(policy_value '.eagle_eval.enabled' 'false')" = "true" ]; then
    warn "Eagle Eval CLI: missing but enabled by policy"
  else
    warn "Eagle Eval CLI: optional and not installed"
  fi
}

cmd_status() {
  info "Governance status for $PROJECT_DIR"
  status_line "Policy" ".eagle-governance.json present" "not installed" "$PROJECT_DIR/.eagle-governance.json"
  status_eagle_mem_bridge
  status_eagle_eval_pack
  for target in "${TARGETS[@]}"; do
    case "$target" in
      claude)
        status_line "Claude hook" "installed" "missing" "$PROJECT_DIR/.claude/hooks/eagle-governance.sh"
        if settings_contains_governance "$PROJECT_DIR/.claude/settings.json"; then ok "Claude settings: wired"; else warn "Claude settings: not wired"; fi
        ;;
      codex)
        status_line "Codex hook" "installed" "missing" "$PROJECT_DIR/.codex/hooks/eagle-governance.sh"
        if settings_contains_governance "$PROJECT_DIR/.codex/hooks.json"; then ok "Codex hooks: wired"; else warn "Codex hooks: not wired"; fi
        ;;
      grok)
        warn "Grok Build: advisory only in v1"
        ;;
      antigravity)
        warn "Antigravity: advisory only in v1"
        ;;
    esac
  done
}

cmd_verify() {
  command -v jq >/dev/null || { err "jq is required for govern verify"; exit 1; }
  local failed=0
  local template="$SOURCE_DIR/eagle-governance/references/eagle-governance.sh"
  local eval_pack="$SOURCE_DIR/eagle-governance/references/eagle-eval-governance-pack.json"
  bash -n "$template" || failed=1
  [ -f "$eval_pack" ] && jq empty "$eval_pack" || failed=1
  if [ "$DRY_RUN" = true ]; then
    ok "Governance templates validated"
    return "$failed"
  fi

  [ -f "$PROJECT_DIR/.eagle-governance.json" ] && jq empty "$PROJECT_DIR/.eagle-governance.json" || failed=1
  for target in "${TARGETS[@]}"; do
    case "$target" in
      claude)
        [ -x "$PROJECT_DIR/.claude/hooks/eagle-governance.sh" ] || failed=1
        settings_contains_governance "$PROJECT_DIR/.claude/settings.json" || failed=1
        [ -f "$PROJECT_DIR/CLAUDE.md" ] && grep -q "eagle-governance:start" "$PROJECT_DIR/CLAUDE.md" || failed=1
        ;;
      codex)
        [ -x "$PROJECT_DIR/.codex/hooks/eagle-governance.sh" ] || failed=1
        settings_contains_governance "$PROJECT_DIR/.codex/hooks.json" || failed=1
        [ -f "$PROJECT_DIR/AGENTS.md" ] && grep -q "eagle-governance:start" "$PROJECT_DIR/AGENTS.md" || failed=1
        ;;
      grok|antigravity)
        [ -f "$PROJECT_DIR/AGENTS.md" ] && grep -q "eagle-governance:start" "$PROJECT_DIR/AGENTS.md" || failed=1
        ;;
    esac
  done

  if [ "$failed" -eq 0 ]; then
    ok "Governance verification passed"
  else
    err "Governance verification failed"
  fi
  return "$failed"
}

main() {
  local subcommand="${1:-help}"
  [ "$#" -gt 0 ] && shift
  parse_common_args "$@"

  case "$subcommand" in
    apply) cmd_apply ;;
    status) cmd_status ;;
    verify) cmd_verify ;;
    help|--help|-h) usage ;;
    *) err "Unknown govern command: $subcommand"; usage; exit 1 ;;
  esac
}

main "$@"
