---
name: eagle-spectral-review
description: "Route Spectral review requests to the correct Eagle specialist. Use when the user says spectral agents, spectral review, full spectrum review, run review specialists, review this PR with agents, choose the right review agents, or asks for code review without naming a specialist. Do not default to plan, investigate, or ship unless the user is planning, debugging, or shipping."
---

# Eagle Spectral Review

Use this skill as the routing layer for Eagle's Spectral review system. Its job
is to select the right specialist reviewers and avoid sending every broad
"Spectral Agents" request to the lifecycle agents.

## Core Rule

Do not pick `eagle-spectral-plan`, `eagle-spectral-investigate`, or
`eagle-spectral-ship` for a generic code review.

Use those lifecycle agents only when the user's intent is clearly:

- Plan: scope a feature, compare approaches, design architecture before coding.
- Investigate: debug a concrete failure or find a root cause.
- Ship: run final gates, clean a diff, prepare a PR, or check merge readiness.

For reviews, choose from the specialist matrix below.

## Specialist Matrix

- Security risk, auth, secrets, injection, dependency exposure:
  `eagle-security-audit`
- Architecture, coupling, boundaries, module structure:
  `eagle-architecture-review`
- Performance, memory, N+1 queries, bundle size, resource usage:
  `eagle-performance-review`
- Maintainability, dead code, naming, duplication, tests:
  `eagle-code-quality`
- Frontend UX states, loading, errors, forms, responsive behavior:
  `eagle-ux-code-review`
- WCAG, keyboard navigation, ARIA, semantic HTML, contrast:
  `eagle-accessibility-review`
- API routes, contracts, status codes, pagination, versioning:
  `eagle-api-review`
- Transactions, partial writes, races, data loss, validation drift:
  `eagle-data-integrity`
- Schema, migrations, indexes, ORM query patterns:
  `eagle-database-review`

## Default Bundles

When the user asks for "Spectral Agents" without a focus area, inspect the
project surface and choose a small bundle:

- Backend API: `eagle-security-audit`, `eagle-api-review`,
  `eagle-code-quality`
- Frontend app: `eagle-ux-code-review`, `eagle-accessibility-review`,
  `eagle-code-quality`
- Database-heavy work: `eagle-database-review`, `eagle-data-integrity`,
  `eagle-performance-review`
- Broad full-stack review: `eagle-security-audit`, `eagle-code-quality`,
  plus any obviously relevant API, UX, accessibility, database, data-integrity,
  architecture, or performance specialist.

Prefer two or three specialists. Use more only when the scope is explicitly
full-spectrum or the changed files justify it.

## Output

State the selected specialists and why. If the host agent supports subagents,
run them. If it does not, apply the selected specialist instructions directly
from the matching agent files or summarize the routing plan for the user.
