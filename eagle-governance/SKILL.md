---
name: eagle-governance
description: >
  Install hook-based engineering governance for agent-led projects. Use when the user says:
  'govern this project', 'install governance hooks', 'agent governance', 'context bloat guard',
  'hook-based engineering governance', 'stop agents ignoring instructions', or asks to make
  AGENTS.md / CLAUDE.md enforceable through hooks.
---

# Eagle Governance

Install a project-local governance runtime that keeps instruction files small and lets hooks enforce the important rules.

## What this does

1. Adds a small governance policy file: `.eagle-governance.json`
2. Installs hook scripts for Claude Code and Codex when those targets are selected
3. Adds small managed routing blocks to `AGENTS.md` and/or `CLAUDE.md`
4. Configures Grok Build through its Claude Code compatibility layer and Antigravity through `.agents/hooks.json`
5. Verifies hook scripts, JSON wiring, and instruction shims
6. Partners with Eagle Mem when available for durable handoff mirroring and feature-verification visibility
7. Ships an optional Eagle Eval governance scenario pack for regression checks

## Commands

```bash
eagle-skills govern status --target all
eagle-skills govern apply --target all --mode warn
eagle-skills govern verify --target all
```

Use `--dry-run` before applying when you want to preview writes:

```bash
eagle-skills govern apply --target all --mode warn --dry-run
```

## Default policy

- Default mode is `warn`
- Hard blocks remain active for destructive commands, secret-file writes, outside-root writes, and high-risk context handoff
- Context bloat produces `.eagle-governance/handoff.md` and blocks further implementation at high risk
- Eagle Mem bridge defaults to `auto`: Governance works without Eagle Mem, but mirrors handoffs and surfaces pending feature verification when Eagle Mem is installed
- Eagle Eval is optional and never runs inside hooks; use the governance pack when you want regression tests for hook behavior
- `AGENTS.md` and `CLAUDE.md` remain shims; do not duplicate the full policy there

## Workflow

1. Run `eagle-skills govern status --target all`
2. Run `eagle-skills govern apply --target all --mode warn --dry-run`
3. Run `eagle-skills govern apply --target all --mode warn`
4. Run `eagle-skills govern verify --target all`
5. For Codex, open `/hooks` and trust the new project hooks when prompted
6. For Claude Code, restart or resume the project session so new hooks load
7. If Eagle Mem is installed, confirm `govern status` reports the bridge as available

## Output

Return a short PM-readable report:

```text
Eagle Governance:
  Policy: installed
  Claude Code: hooks installed and wired
  Codex: hooks installed and wired; trust review may be required
  Eagle Mem: bridge available; handoff mirror enabled
  Eagle Eval: governance pack available; CLI optional
  Grok Build: Claude-compatible hooks installed and wired
  Antigravity: hooks installed and wired
```

## Principles

- Hooks are control; instruction files are routing context
- Keep injected context tiny
- Treat each provider's hook output contract separately
- Let Eagle Mem own durable recall, orchestration lanes, and release-boundary feature verification
- Let Eagle Eval test governance behavior outside the live hook path
- Prefer warn-first adoption, then tighten gates once the project trusts the workflow
- Never overwrite user-written `AGENTS.md`, `CLAUDE.md`, or settings content
