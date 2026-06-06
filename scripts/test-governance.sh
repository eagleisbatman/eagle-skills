#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

repo="$TMP/repo"
mkdir -p "$repo/.claude"
cd "$repo"
git init -q

cat > .claude/settings.json <<'JSON'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo existing"
          }
        ]
      }
    ]
  }
}
JSON

printf '# Existing instructions\n' > AGENTS.md
cat > .eagle-governance.json <<'JSON'
{
  "mode": "warn",
  "gates": {
    "tests_required": false,
    "context_budget": true
  },
  "context_budget": {
    "warn_bytes": 500000,
    "handoff_bytes": 900000,
    "max_changed_files": 25
  }
}
JSON

fakebin="$TMP/fakebin"
mkdir -p "$fakebin"
cat > "$fakebin/eagle-mem" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${EAGLE_MEM_FAKE_LOG:?}"
case "${1:-} ${2:-}" in
  "tasks add")
    echo "Task fake created"
    ;;
  "statusline ")
    echo "Eagle vtest | turn ${EAGLE_MEM_FAKE_TURN:-10}/${EAGLE_MEM_FAKE_TURN_MAX:-30}"
    ;;
  "feature pending")
    if [ "${EAGLE_MEM_FAKE_PENDING:-0}" -gt 0 ]; then
      echo "  Pending verification (repo)"
      echo "  ${EAGLE_MEM_FAKE_PENDING} check(s) must be verified or waived before release-boundary commands."
      echo "  1. fake-feature #1"
    else
      echo "ok No pending feature verifications for 'repo'"
    fi
    ;;
  *)
    if [ "${1:-}" = "search" ]; then
      echo '[{"summary":"npm test passed"}]'
    else
      echo "fake eagle-mem"
    fi
    ;;
esac
SH
chmod +x "$fakebin/eagle-mem"

EAGLE_SKILLS_SOURCE_DIR="$ROOT" "$ROOT/bin/eagle-skills" govern apply --target all --mode warn
EAGLE_SKILLS_SOURCE_DIR="$ROOT" "$ROOT/bin/eagle-skills" govern apply --target all --mode warn
EAGLE_SKILLS_SOURCE_DIR="$ROOT" "$ROOT/bin/eagle-skills" govern verify --target all

grep -q "echo existing" .claude/settings.json
[ "$(grep -c "eagle-governance:start" AGENTS.md)" -eq 1 ]
[ "$(grep -c "eagle-governance:start" CLAUDE.md)" -eq 1 ]
jq empty .claude/settings.json
jq empty .codex/hooks.json
jq empty .agents/hooks.json
jq -e '
  .eagle_mem.enabled == "auto" and
  .eagle_mem.handoff_mirror == true and
  .eagle_eval.governance_pack == true and
  .gates.tests_required == false and
  .context_budget.suggest_percent == 70 and
  .context_budget.handoff_percent == 85 and
  .context_budget.transcript_warn_bytes == 5000000 and
  .context_budget.transcript_handoff_bytes == 0 and
  (.context_budget | has("warn_bytes") | not) and
  (.context_budget | has("handoff_bytes") | not) and
  (.context_budget | has("max_changed_files") | not)
' .eagle-governance.json >/dev/null
grep -q "exec_command" .codex/hooks.json
jq -e '.hooks.SessionStart[] | select(.matcher == "startup|resume|compact")' .claude/settings.json >/dev/null
jq -e '.statusLine.command | contains("eagle-governance-statusline.sh")' .claude/settings.json >/dev/null
jq -e '.hooks.SessionStart[] | select(.matcher == "startup|resume|compact")' .codex/hooks.json >/dev/null
jq -e '."eagle-governance".PreInvocation[0].command | contains("EAGLE_GOVERNANCE_EVENT=PreInvocation")' .agents/hooks.json >/dev/null
jq -e '."eagle-governance".Stop[0].command | contains("EAGLE_GOVERNANCE_EVENT=Stop")' .agents/hooks.json >/dev/null

status_output="$(PATH="$fakebin:$PATH" EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-status.log" EAGLE_MEM_FAKE_PENDING=2 EAGLE_SKILLS_SOURCE_DIR="$ROOT" "$ROOT/bin/eagle-skills" govern status --target all)"
printf '%s\n' "$status_output" | grep -q "Eagle Mem bridge: available"
printf '%s\n' "$status_output" | grep -q "Eagle Mem feature verification: 2 pending"
printf '%s\n' "$status_output" | grep -q "Eagle Eval governance pack: available"
printf '%s\n' "$status_output" | grep -q "Claude context statusline: installed"

statusline_output="$(printf '%s\n' '{"model":{"display_name":"Sonnet"},"workspace":{"current_dir":"'"$repo"'"},"context_window":{"used_percentage":72}}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-statusline.log" EAGLE_MEM_FAKE_TURN=10 PATH="$fakebin:$PATH" .claude/hooks/eagle-governance-statusline.sh)"
printf '%s\n' "$statusline_output" | grep -q "ctx 72%"
jq -e '.context_window.used_percentage == 72' .eagle-governance/context-state.json >/dev/null

block_output="$(printf '%s\n' '{"hook_event_name":"PreToolUse","cwd":"'"$repo"'","tool_input":{"command":"rm -rf /"}}' | .claude/hooks/eagle-governance.sh)"
echo "$block_output" | jq -e '.decision == "block"' >/dev/null
echo "$block_output" | jq -e '.hookSpecificOutput.hookEventName == "PreToolUse" and (.hookSpecificOutput | has("additionalContext") | not)' >/dev/null

outside_output="$(printf '%s\n' '{"hook_event_name":"PreToolUse","tool_name":"Write","cwd":"'"$repo"'","tool_input":{"file_path":"'"$TMP/outside-root.txt"'","content":"x"}}' | .claude/hooks/eagle-governance.sh)"
echo "$outside_output" | jq -e '.decision == "block"' >/dev/null

mkdir -p db
printf '{"dependencies":{"left-pad":"1.3.0"}}\n' > package.json
printf 'create table example (id integer primary key);\n' > db/schema.sql
jq '.diff_budget.files = 1 | .diff_budget.lines = 0 | .context_budget.transcript_handoff_bytes = 0 | .eagle_mem.enabled = "off"' .eagle-governance.json > "$TMP/policy.json"
mv "$TMP/policy.json" .eagle-governance.json
warn_output="$(printf '%s\n' '{"hook_event_name":"PostToolUse","cwd":"'"$repo"'","tool_input":{"command":"echo changed"}}' | .claude/hooks/eagle-governance.sh)"
echo "$warn_output" | jq -e '.hookSpecificOutput.additionalContext | contains("database/schema") and contains("dependency manifest") and contains("diff budget")' >/dev/null

rm -rf .eagle-governance
printf '{"mode":"warn","gates":{"context_budget":true},"context_budget":{"transcript_warn_bytes":1,"transcript_handoff_bytes":0,"suggest_percent":70,"handoff_percent":85,"suggest_turns":24,"handoff_turns":30},"eagle_mem":{"enabled":"off"}}\n' > .eagle-governance.json
transcript="$TMP/transcript.jsonl"
printf '%s\n' "large transcript" > "$transcript"
read_handoff_output="$(printf '%s\n' '{"hook_event_name":"PostToolUse","cwd":"'"$repo"'","transcript_path":"'"$transcript"'","tool_input":{"command":"rg generationRuns packages/db/src/schema"}}' | .claude/hooks/eagle-governance.sh)"
echo "$read_handoff_output" | jq -e '(.decision // "") != "block" and (.hookSpecificOutput.additionalContext | contains("context budget warning")) and (.hookSpecificOutput.additionalContext | contains("transcript bytes"))' >/dev/null
[ ! -f .eagle-governance/handoff.md ]
printf '%s\n' '{"hook_event_name":"PreCompact","trigger":"manual","cwd":"'"$repo"'"}' | .claude/hooks/eagle-governance.sh
session_start_output="$(printf '%s\n' '{"hook_event_name":"SessionStart","source":"startup","cwd":"'"$repo"'"}' | .claude/hooks/eagle-governance.sh)"
echo "$session_start_output" | jq -e '.hookSpecificOutput.additionalContext | contains("handoff.md")' >/dev/null
post_compact_output="$(printf '%s\n' '{"hook_event_name":"PostCompact","trigger":"manual","cwd":"'"$repo"'","compact_summary":"Compacted summary from Claude."}' | .claude/hooks/eagle-governance.sh)"
[ -z "$post_compact_output" ]
[ -f .eagle-governance/restore-receipt.md ]
compact_start_output="$(printf '%s\n' '{"hook_event_name":"SessionStart","source":"compact","cwd":"'"$repo"'"}' | .claude/hooks/eagle-governance.sh)"
echo "$compact_start_output" | jq -e '.hookSpecificOutput.additionalContext | contains("restore-receipt.md")' >/dev/null
mkdir -p .eagle-governance
printf '{"context_window":{"used_percentage":90}}\n' > .eagle-governance/context-state.json
pre_write_handoff_output="$(printf '%s\n' '{"hook_event_name":"PreToolUse","cwd":"'"$repo"'","transcript_path":"'"$transcript"'","tool_input":{"command":"touch local-change.txt"}}' | .claude/hooks/eagle-governance.sh)"
echo "$pre_write_handoff_output" | jq -e '.decision == "block" and (.reason | contains("write-like tool use"))' >/dev/null
post_write_handoff_output="$(printf '%s\n' '{"hook_event_name":"PostToolUse","cwd":"'"$repo"'","transcript_path":"'"$transcript"'","tool_input":{"command":"echo x > local-change.txt"}}' | .claude/hooks/eagle-governance.sh)"
echo "$post_write_handoff_output" | jq -e '.decision == "block" and (.reason | contains("write-like implementation"))' >/dev/null
handoff_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'","transcript_path":"'"$transcript"'"}' | .claude/hooks/eagle-governance.sh)"
echo "$handoff_output" | jq -e '.decision == "block"' >/dev/null
echo "$handoff_output" | jq -e 'has("hookSpecificOutput") | not' >/dev/null
recursive_stop_output="$(printf '%s\n' '{"hook_event_name":"Stop","stop_hook_active":true,"cwd":"'"$repo"'","transcript_path":"'"$transcript"'"}' | .claude/hooks/eagle-governance.sh)"
[ -z "$recursive_stop_output" ]
[ -f .eagle-governance/handoff.md ]

antigravity_pre_output="$(printf '%s\n' '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /","Cwd":"'"$repo"'"}},"workspacePaths":["'"$repo"'"],"transcriptPath":"'"$transcript"'"}' | EAGLE_GOVERNANCE_PROVIDER=antigravity EAGLE_GOVERNANCE_EVENT=PreToolUse .agents/hooks/eagle-governance.sh)"
echo "$antigravity_pre_output" | jq -e '.decision == "deny"' >/dev/null
antigravity_invocation_output="$(printf '%s\n' '{"workspacePaths":["'"$repo"'"],"transcriptPath":"'"$transcript"'","invocationNum":3,"initialNumSteps":10}' | EAGLE_GOVERNANCE_PROVIDER=antigravity EAGLE_GOVERNANCE_EVENT=PreInvocation .agents/hooks/eagle-governance.sh)"
echo "$antigravity_invocation_output" | jq -e '.injectSteps[0].ephemeralMessage | contains("context risk is high")' >/dev/null
antigravity_stop_output="$(printf '%s\n' '{"workspacePaths":["'"$repo"'"],"transcriptPath":"'"$transcript"'","executionNum":1,"terminationReason":"model_stop","fullyIdle":true}' | EAGLE_GOVERNANCE_PROVIDER=antigravity EAGLE_GOVERNANCE_EVENT=Stop .agents/hooks/eagle-governance.sh)"
echo "$antigravity_stop_output" | jq -e '.decision == "continue"' >/dev/null

rm -rf .eagle-governance
mkdir -p .eagle-governance
printf '{"context_window":{"used_percentage":90}}\n' > .eagle-governance/context-state.json
printf '{"mode":"warn","gates":{"context_budget":true},"context_budget":{"transcript_warn_bytes":1,"transcript_handoff_bytes":0,"suggest_percent":70,"handoff_percent":85},"eagle_mem":{"enabled":"auto","handoff_mirror":true}}\n' > .eagle-governance.json
handoff_mirror_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'","transcript_path":"'"$transcript"'"}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-handoff.log" PATH="$fakebin:$PATH" .claude/hooks/eagle-governance.sh)"
echo "$handoff_mirror_output" | jq -e '.decision == "block"' >/dev/null
grep -q "tasks add" "$TMP/eagle-mem-handoff.log"

rm -rf .eagle-governance
printf '{"mode":"warn","gates":{"tests_required":false,"context_budget":true},"context_budget":{"transcript_warn_bytes":999999999,"transcript_handoff_bytes":0},"eagle_mem":{"enabled":"auto","feature_pending_gate":true}}\n' > .eagle-governance.json
feature_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'"}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-feature.log" EAGLE_MEM_FAKE_PENDING=2 PATH="$fakebin:$PATH" .claude/hooks/eagle-governance.sh)"
echo "$feature_output" | jq -e '.systemMessage | contains("2 pending feature") and (contains("changed files detected") | not)' >/dev/null

printf '{"mode":"warn","gates":{"tests_required":true,"context_budget":true},"context_budget":{"transcript_warn_bytes":999999999,"transcript_handoff_bytes":0},"eagle_mem":{"enabled":"auto","feature_pending_gate":false,"test_history_lookup":true}}\n' > .eagle-governance.json
test_history_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'"}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-search.log" PATH="$fakebin:$PATH" .claude/hooks/eagle-governance.sh)"
echo "$test_history_output" | jq -e '.systemMessage | contains("prior test/lint history")' >/dev/null

echo "Governance fixture tests passed"
