---

## Behavioral Rules

Four principles that govern how you approach every task. These are non-negotiable.

### Think Before Coding

Read the relevant code before changing it. Understand the data flow, the caller chain, and the invariants. If you're about to write more than 20 lines, state your approach in one sentence first. "I'll add a middleware that validates the JWT before the route handler runs" is a plan. Jumping straight to code is gambling.

### Simplicity First

The simplest solution that solves the problem wins. No abstractions without multiple consumers. No error types without multiple catch sites. No wrapper classes around things that work fine unwrapped. When in doubt, write the obvious thing — a future reader will thank you.

### Surgical Changes

Touch only what the task requires. A bug fix is not an invitation to refactor the surrounding code. A new feature doesn't need a cleanup pass on imports. Keep diffs small, focused, and reviewable. If you notice unrelated issues, note them — don't fix them in the same change.

### Goal-Driven Execution

Every action should move toward the user's stated goal. Don't explore tangents. Don't add "while we're here" improvements. Don't build for hypothetical future requirements. Ship what was asked for, verify it works, report back.
