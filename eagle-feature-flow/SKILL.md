---
name: eagle-feature-flow
description: >
  Structured development workflow that sequences planning, building, testing, and shipping.
  Use when the user says: 'feature flow', 'build this feature', 'implement this', 'dev workflow',
  'eagle flow', 'start feature', 'build and ship', 'full dev cycle', 'plan and build',
  'implement and review'. Also trigger when the user describes a feature to build and expects
  the full cycle: planning, implementation, testing, review, and commit.
---

# Eagle Feature Flow

A structured development workflow that takes a feature from idea to committed code. Sequences nine phases, orchestrating existing eagle-skills components at each gate.

## When to use

- User describes a feature to build (not a bug fix or quick change)
- User says "build this", "implement this feature", "full dev cycle"
- Any task that benefits from plan → build → test → review → ship

## The Nine Phases

Execute these phases in strict order. Do NOT skip phases. If a phase fails, fix and re-run that phase before advancing.

### Phase 1: Plan

Enter plan mode. Analyze the codebase to understand:
- Where the change fits architecturally
- Which files need to be created or modified
- What dependencies exist
- What could break

State your approach in 2-3 sentences. Get user confirmation before proceeding.

### Phase 2: Tasks

Break the plan into discrete tasks with acceptance criteria. Use TaskCreate for each task.

Each task must have:
- **Subject**: What to do (imperative form)
- **Description**: Acceptance criteria — specific, testable conditions that define "done"

Example:
```
Subject: Add rate limiting middleware to /api/auth routes
Description:
  AC1: Requests exceeding 10/min per IP return 429
  AC2: Rate limit headers (X-RateLimit-Remaining) present on every response
  AC3: Existing auth tests still pass
```

Order tasks by dependency. Set blockedBy relationships where needed.

### Phase 3: Build

Implement each task in order. For each task:
1. Mark it `in_progress`
2. Write the code
3. Verify acceptance criteria are met
4. Mark it `completed`

Follow the project's conventions. Read before writing. Keep diffs surgical.

### Phase 4: Test

Run the project's test suite. The exact command depends on the stack:
- `npm test` / `pnpm test` / `bun test` for JS/TS
- `pytest` for Python
- `cargo test` for Rust
- `go test ./...` for Go
- Whatever `test` script is in package.json or the project's test runner

If no test suite exists, write tests for the new code before running them.

**Gate:** All tests must pass. If any fail, fix and re-run until green.

### Phase 5: Spectral Review

Run the relevant review specialists on the changed files. Pick agents based on the stack:
- Backend → `eagle-security-audit`, `eagle-code-quality`
- Frontend → `eagle-ux-code-review`, `eagle-accessibility-review`
- Database → `eagle-database-review`, `eagle-data-integrity`

**Gate:** Address all HIGH and CRITICAL findings. MEDIUM findings are addressed if the fix is straightforward. LOW findings are noted but not blocking.

### Phase 6: Fix

Apply fixes from the spectral review. This may involve:
- Security patches
- Error handling improvements
- Code quality fixes

After fixing, return to Phase 4 (test again) to verify fixes didn't break anything.

### Phase 7: Anti-Slop

Run the eagle-anti-slop skill on all new and modified code. Look for:
- Over-abstraction (wrappers nobody needs)
- Over-commenting (comments that restate the code)
- Over-logging (log lines that add no diagnostic value)
- Over-typing (type gymnastics that don't add safety)
- AI-typical patterns (defensive checks for impossible states)

Strip slop. Keep the code lean.

### Phase 8: Final Test

Run the full test suite one more time. This catches regressions from Phase 6 and Phase 7 changes.

**Gate:** All tests must pass. No exceptions.

### Phase 9: Commit

Create a git commit (or multiple commits if the work is logically separable).

Commit message rules:
- First line: imperative mood, under 72 characters, describes the **why** not the what
- Body (if needed): bullet points explaining key decisions
- No "fix: fix the thing" — say what was actually wrong
- No "refactor: refactor code" — say what changed and why
- Include `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`

If the work is large, split into logical commits (e.g., one for the feature, one for tests, one for config changes). Each commit should be independently valid — don't commit broken intermediate states.

Do NOT push unless the user explicitly asks.

## Phase Flow Diagram

```
Plan → Tasks → Build → Test ──→ Spectral Review → Fix ─┐
                         ↑                               │
                         └───────────── Test Again ←─────┘
                                           │
                                       Anti-Slop
                                           │
                                       Final Test
                                           │
                                        Commit
```

## Failure Handling

- **Test failure (Phase 4/8):** Fix the failing tests. Re-run. Do not advance until green.
- **Spectral review findings (Phase 5):** Fix HIGH/CRITICAL. Re-test. Then advance.
- **Anti-slop findings (Phase 7):** Strip the slop. Re-test. Then advance.
- **Build error (Phase 3):** Debug, fix, continue. Do not skip to testing with broken code.

## What this skill does NOT do

- It does not push to remote (user must explicitly request)
- It does not create PRs (use eagle-spectral-ship for that)
- It does not deploy (use the project's deployment workflow)
- It does not replace human judgment on the plan — Phase 1 requires user confirmation
