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

fakebin="$TMP/fakebin"
mkdir -p "$fakebin"
cat > "$fakebin/eagle-mem" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${EAGLE_MEM_FAKE_LOG:?}"
case "${1:-} ${2:-}" in
  "tasks add")
    echo "Task fake created"
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
jq -e '.eagle_mem.enabled == "auto" and .eagle_mem.handoff_mirror == true and .eagle_eval.governance_pack == true' .eagle-governance.json >/dev/null
grep -q "exec_command" .codex/hooks.json

status_output="$(PATH="$fakebin:$PATH" EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-status.log" EAGLE_MEM_FAKE_PENDING=2 EAGLE_SKILLS_SOURCE_DIR="$ROOT" "$ROOT/bin/eagle-skills" govern status --target all)"
printf '%s\n' "$status_output" | grep -q "Eagle Mem bridge: available"
printf '%s\n' "$status_output" | grep -q "Eagle Mem feature verification: 2 pending"
printf '%s\n' "$status_output" | grep -q "Eagle Eval governance pack: available"

block_output="$(printf '%s\n' '{"hook_event_name":"PreToolUse","cwd":"'"$repo"'","tool_input":{"command":"rm -rf /"}}' | .claude/hooks/eagle-governance.sh)"
echo "$block_output" | jq -e '.decision == "block"' >/dev/null

outside_output="$(printf '%s\n' '{"hook_event_name":"PreToolUse","tool_name":"Write","cwd":"'"$repo"'","tool_input":{"file_path":"'"$TMP/outside-root.txt"'","content":"x"}}' | .claude/hooks/eagle-governance.sh)"
echo "$outside_output" | jq -e '.decision == "block"' >/dev/null

mkdir -p db
printf '{"dependencies":{"left-pad":"1.3.0"}}\n' > package.json
printf 'create table example (id integer primary key);\n' > db/schema.sql
jq '.diff_budget.files = 1 | .diff_budget.lines = 0 | .context_budget.handoff_bytes = 999999999 | .eagle_mem.enabled = "off"' .eagle-governance.json > "$TMP/policy.json"
mv "$TMP/policy.json" .eagle-governance.json
warn_output="$(printf '%s\n' '{"hook_event_name":"PostToolUse","cwd":"'"$repo"'","tool_input":{"command":"echo changed"}}' | .claude/hooks/eagle-governance.sh)"
echo "$warn_output" | jq -e '.hookSpecificOutput.additionalContext | contains("database/schema") and contains("dependency manifest") and contains("diff budget")' >/dev/null

printf '{"mode":"warn","gates":{"context_budget":true},"context_budget":{"warn_bytes":1,"handoff_bytes":1,"max_changed_files":99},"eagle_mem":{"enabled":"off"}}\n' > .eagle-governance.json
transcript="$TMP/transcript.jsonl"
printf '%s\n' "large transcript" > "$transcript"
handoff_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'","transcript_path":"'"$transcript"'"}' | .claude/hooks/eagle-governance.sh)"
echo "$handoff_output" | jq -e '.decision == "block"' >/dev/null
[ -f .eagle-governance/handoff.md ]

rm -rf .eagle-governance
printf '{"mode":"warn","gates":{"context_budget":true},"context_budget":{"warn_bytes":1,"handoff_bytes":1,"max_changed_files":99},"eagle_mem":{"enabled":"auto","handoff_mirror":true}}\n' > .eagle-governance.json
handoff_mirror_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'","transcript_path":"'"$transcript"'"}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-handoff.log" PATH="$fakebin:$PATH" .claude/hooks/eagle-governance.sh)"
echo "$handoff_mirror_output" | jq -e '.decision == "block"' >/dev/null
grep -q "tasks add" "$TMP/eagle-mem-handoff.log"

printf '{"mode":"warn","gates":{"tests_required":false,"context_budget":true},"context_budget":{"warn_bytes":999999999,"handoff_bytes":999999999,"max_changed_files":99},"eagle_mem":{"enabled":"auto","feature_pending_gate":true}}\n' > .eagle-governance.json
feature_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'"}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-feature.log" EAGLE_MEM_FAKE_PENDING=2 PATH="$fakebin:$PATH" .claude/hooks/eagle-governance.sh)"
echo "$feature_output" | jq -e '.hookSpecificOutput.additionalContext | contains("2 pending feature")' >/dev/null

printf '{"mode":"warn","gates":{"tests_required":true,"context_budget":true},"context_budget":{"warn_bytes":999999999,"handoff_bytes":999999999,"max_changed_files":99},"eagle_mem":{"enabled":"auto","feature_pending_gate":false,"test_history_lookup":true}}\n' > .eagle-governance.json
test_history_output="$(printf '%s\n' '{"hook_event_name":"Stop","cwd":"'"$repo"'"}' | EAGLE_MEM_FAKE_LOG="$TMP/eagle-mem-search.log" PATH="$fakebin:$PATH" .claude/hooks/eagle-governance.sh)"
echo "$test_history_output" | jq -e '.hookSpecificOutput.additionalContext | contains("prior test/lint history")' >/dev/null

echo "Governance fixture tests passed"
