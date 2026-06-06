#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash -n bin/eagle-skills
bash -n install.sh
bash -n scripts/govern.sh
bash -n scripts/test-governance.sh
bash -n eagle-governance/references/eagle-governance.sh

source <(sed '/^main "\$@"/d' bin/eagle-skills)

skill_count=${#SKILL_DIRS[@]}
for array_name in SKILL_NAMES SKILL_DESCS SKILL_COMMANDS SKILL_TRIGGERS SKILL_INPUTS SKILL_OUTPUTS SKILL_EXAMPLES; do
  eval "count=\${#$array_name[@]}"
  if [ "$count" -ne "$skill_count" ]; then
    echo "Array length mismatch: $array_name=$count, SKILL_DIRS=$skill_count" >&2
    exit 1
  fi
done

agent_count=${#AGENT_FILES[@]}
for array_name in AGENT_NAMES AGENT_DESCS AGENT_CATEGORIES; do
  eval "count=\${#$array_name[@]}"
  if [ "$count" -ne "$agent_count" ]; then
    echo "Array length mismatch: $array_name=$count, AGENT_FILES=$agent_count" >&2
    exit 1
  fi
done

for skill in "${SKILL_DIRS[@]}"; do
  if [ ! -f "$skill/SKILL.md" ]; then
    echo "Missing skill file: $skill/SKILL.md" >&2
    exit 1
  fi
done

if [ ! -f "docs/skills/governance.md" ]; then
  echo "Missing governance docs: docs/skills/governance.md" >&2
  exit 1
fi

if [ ! -f "eagle-governance/references/eagle-eval-governance-pack.json" ]; then
  echo "Missing governance eval pack: eagle-governance/references/eagle-eval-governance-pack.json" >&2
  exit 1
fi

jq empty eagle-governance/references/eagle-eval-governance-pack.json

jq empty < <(cat <<'JSON'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/eagle-governance.sh"
          }
        ]
      }
    ]
  }
}
JSON
)

for agent in "${AGENT_FILES[@]}"; do
  if [ ! -f "agents/${agent}.md" ]; then
    echo "Missing agent file: agents/${agent}.md" >&2
    exit 1
  fi
done

pkg_version="$(node -p "require('./package.json').version")"
cli_version="${VERSION}"
if [ "$pkg_version" != "$cli_version" ]; then
  echo "Version mismatch: package.json=$pkg_version, bin/eagle-skills=$cli_version" >&2
  exit 1
fi

bin/eagle-skills govern help >/dev/null
bin/eagle-skills govern status --target all >/dev/null
bin/eagle-skills govern apply --dry-run --target all >/dev/null
bin/eagle-skills govern verify --dry-run --target all >/dev/null
bash scripts/test-governance.sh >/dev/null

echo "Eagle Skills validation passed: $skill_count skills, $agent_count agents, version $pkg_version"
