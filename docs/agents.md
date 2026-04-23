# Agents

14 autonomous agents for code review, debugging, planning, and shipping. Each agent applies a 3-lens analytical framework and works iteratively — auditing, fixing, and re-auditing until the code passes.

## How agents work

Unlike skills (which follow structured workflows with user input), agents are autonomous. Tell Claude what you need and the right agent runs, audits your code, fixes issues, and re-audits in cycles.

Agents are dispatched by Claude's Agent tool. You can ask for one by name ("run eagle-security-audit") or describe what you need and the orchestrator picks the right specialist.

## Skills vs Agents

| | Skills | Agents |
|---|---|---|
| **Invocation** | Slash commands (`/eagle-ux-review`) | Agent tool dispatch ("run eagle-triad-review") |
| **Install location** | `~/.claude/skills/<name>/SKILL.md` | `~/.claude/agents/<name>.md` |
| **Behavior** | Structured workflows with user input | Autonomous audit-fix-reaudit cycles |
| **Best for** | Domain expertise, structured deliverables | Code review, debugging, shipping |

---

## Orchestrator

### eagle-spectral-suite

Detects your intent and tech stack, then dispatches the right specialist agents. Ask it to "review everything" and it figures out which agents to run.

```
You: Run a spectral review
You: Review everything
You: Run all the review agents
```

---

## Lifecycle agents

For the stages of development — planning, debugging, shipping.

### eagle-spectral-plan

Planning and architecture design. Asks forcing questions, evaluates approaches through Feasibility / Risk / Maintainability lenses, outputs a concrete implementation plan. Does not modify code.

```
You: Help me plan this feature
You: What's the right architecture for this?
You: Scope this refactor before I start
```

### eagle-spectral-investigate

Root-cause debugging. Collects symptoms, traces code paths, generates ranked hypotheses, and tests them systematically through 3 lenses (Code Path / State & Environment / Change History). Applies fix when root cause is confirmed.

```
You: Debug this failing test
You: Why is this returning null?
You: Find the root cause of this bug
```

### eagle-spectral-ship

Pre-ship pipeline and PR creation. Runs build/test/lint gates, reviews the diff through Quality Gate / Diff Integrity / Release Hygiene lenses, cleans up debug artifacts, and generates a PR.

```
You: Ship this
You: Is this ready to merge?
You: Create a PR for this work
```

---

## Review specialists

Each applies domain-specific lenses and works iteratively until the code passes.

### eagle-triad-review

Single-pass 3-lens review covering security + ops/reliability + maintainability. The broadest reviewer — use when you want comprehensive coverage without running multiple specialists.

### eagle-security-audit

Deep vulnerability hunting: injection vectors, auth flaws, data exposure, supply chain risks. Fixes issues autonomously and re-audits until clean.

### eagle-architecture-review

Structural health: dependency management, separation of concerns, scalability patterns, coupling, cohesion, design pattern usage. Flags architectural debt.

### eagle-performance-review

Bottleneck and resource analysis: memory leaks, inefficient algorithms, unnecessary re-renders, N+1 queries, bundle bloat, resource waste.

### eagle-code-quality

Readability, dead code, duplication, convention violations, missing error handling, test gaps. Cleans up the codebase autonomously.

### eagle-ux-code-review

Frontend code UX patterns: loading states, error handling UX, accessibility basics, responsive design, form validation, empty states, interaction patterns.

### eagle-accessibility-review

WCAG 2.1 AA compliance: semantic HTML, ARIA usage, keyboard navigation, color contrast, screen reader support, focus management, form accessibility.

### eagle-api-review

API design and implementation: endpoint consistency, request/response contracts, error handling, versioning, pagination, rate limiting, REST/GraphQL best practices.

### eagle-data-integrity

Data integrity: race conditions, partial writes, missing transactions, schema mismatches, migration gaps, validation holes, data loss vectors.

### eagle-database-review

Database schema design, SQL queries, migrations, indexes, and ORM usage for correctness, performance, and safety.
