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
3. Grok Build: enforced through Grok's documented Claude Code compatibility layer (`.claude/settings.json`, `.claude/hooks/`, and `CLAUDE.md`)
4. Antigravity: project `.agents/hooks.json` plus `.agents/hooks/eagle-governance.sh`

## Provider notes

- Claude Code compact hooks run only when Claude triggers compaction manually with `/compact` or automatically at the context limit. Eagle Governance cannot force Claude to run `/compact`; hooks are shell callbacks, not slash-command drivers. It writes a handoff before compaction and re-injects the restore receipt on `SessionStart` for `startup`, `resume`, and `compact`.
- Claude Code also gets `.claude/hooks/eagle-governance-statusline.sh`. When wired as `statusLine`, it records Claude's real `context_window.used_percentage` into `.eagle-governance/context-state.json` so the governance hook can distinguish true context pressure from large transcripts or broad diffs.
- Codex project hooks require the project `.codex/` layer and hook definition to be trusted through `/hooks`.
- Grok Build reads Claude Code hooks, skills, agents, and instruction files, so Eagle Governance installs the Claude-compatible hook surface for Grok.
- Antigravity uses its own hook schema. Governance maps blocks to `deny` for `PreToolUse`, `continue` for `Stop`, and transient `injectSteps` for invocation context.

## Gates

- Broad prompt classification
- Destructive command blocking
- Outside-project write blocking
- Dependency and schema-change warnings
- Diff-budget warnings
- Missing-test warnings
- Context-bloat handoff blocking
- Fresh-session restore on startup, resume, and compact
- Eagle Mem pending-feature visibility
- Eagle Mem handoff mirroring

## Context policy

Context handoff uses real pressure signals first:

1. Claude Code context percentage from the governance statusline
2. Eagle Mem turn budget when Eagle Mem is available
3. Optional transcript byte thresholds only when explicitly configured

Defaults:

```json
{
  "context_budget": {
    "suggest_percent": 70,
    "handoff_percent": 85,
    "suggest_turns": 24,
    "handoff_turns": 30,
    "transcript_warn_bytes": 5000000,
    "transcript_handoff_bytes": 0
  }
}
```

Changed-file count and diff size are scope signals, not context-window signals. They warn through the diff-budget gate, but they do not force a fresh-session handoff by default.

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
