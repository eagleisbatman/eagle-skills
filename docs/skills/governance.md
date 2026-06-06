# Eagle Governance

Hook-based engineering governance for large agent-led projects.

## What it does

Eagle Governance installs a project-local runtime that treats `AGENTS.md` and `CLAUDE.md` as small routing shims while hooks enforce the real gates.

It also partners with Eagle Mem when available:

1. Governance owns immediate hook decisions: block, warn, or force handoff.
2. Eagle Mem owns durable recall, task/orchestration state, feature verification, and release-boundary protection.
3. Eagle Eval can optionally regression-test the governance behavior outside the live hook path.

## Command

```bash
eagle-skills govern apply --target all --mode warn
```

Also triggers on: "govern this project", "install governance hooks", "agent governance", "context bloat guard", "hook-based engineering governance".

## Supported targets

1. Claude Code: project `.claude/settings.json` plus `.claude/hooks/eagle-governance.sh`
2. Codex: project `.codex/hooks.json` plus `.codex/hooks/eagle-governance.sh`
3. Grok Build: advisory `AGENTS.md` shim in v1
4. Antigravity: advisory `AGENTS.md` shim in v1

## Gates

- Broad prompt classification
- Destructive command blocking
- Outside-project write blocking
- Dependency and schema-change warnings
- Diff-budget warnings
- Missing-test warnings
- Context-bloat handoff blocking
- Eagle Mem pending-feature visibility
- Eagle Mem handoff mirroring

## Policy bridge

New projects get these bridge defaults in `.eagle-governance.json`:

```json
{
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
```

If Eagle Mem is not installed, Governance still enforces core safety gates. If Eagle Eval is not installed, the scenario pack simply remains available for later regression testing.

## Example

```bash
eagle-skills govern status --target all
eagle-skills govern apply --target all --mode warn --dry-run
eagle-skills govern apply --target all --mode warn
eagle-skills govern verify --target all
```

Optional Eagle Eval pack:

```text
eagle-governance/references/eagle-eval-governance-pack.json
```
