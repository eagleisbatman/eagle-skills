# Eagle Feature Flow

Structured development workflow — plan, build, test, review, ship.

## Command

```
/eagle-feature-flow
```

Also triggers on: "feature flow", "build this feature", "implement this", "dev workflow", "full dev cycle", "plan and build"

## The Nine Phases

| # | Phase | Gate |
|---|-------|------|
| 1 | **Plan** — analyze codebase, state approach, get user confirmation | User approval |
| 2 | **Tasks** — break into tasks with acceptance criteria | All tasks created |
| 3 | **Build** — implement each task in order | All ACs met |
| 4 | **Test** — run full test suite | All tests pass |
| 5 | **Spectral Review** — eagle-triad-review on changed files | HIGH/CRITICAL fixed |
| 6 | **Fix** — apply review findings, re-test | Tests pass again |
| 7 | **Anti-Slop** — eagle-anti-slop on new/modified code | Slop stripped |
| 8 | **Final Test** — full suite one more time | All tests pass |
| 9 | **Commit** — proper commit messages, no push unless asked | Clean git history |

## Flow Diagram

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

## What it orchestrates

- **eagle-triad-review** — Phase 5 security/ops/maintainability review
- **eagle-anti-slop** — Phase 7 AI pattern cleanup
- **TaskCreate/TaskUpdate** — Phase 2-3 task tracking

## Example

```
You: Build a rate-limiting middleware for the auth routes
Claude: [enters plan mode, creates tasks with ACs, implements,
        runs tests, spectral review, anti-slop, commits]
```

## What it does NOT do

- Push to remote (user must ask)
- Create PRs (use eagle-spectral-ship)
- Deploy (use project's deployment workflow)
