# Eagle Skills

**11 skills + 12 agents for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).** Skills give Claude domain expertise via slash commands. Agents are autonomous reviewers that audit, fix, and re-review your code.

### Token saver

Eagle Skills includes a **compact hook system** that saves context window tokens by rewriting verbose Bash commands. 32 regex rules intercept commands like `git log`, `docker ps`, and test runners — replacing them with compact equivalents or filtering noisy output. Add your own rules with `/eagle-compact-add`. [Full details →](docs/compact-hook.md)

## Install

```bash
npm install -g eagle-skills
eagle-skills install
```

Or run directly without installing:

```bash
npx eagle-skills install
```

Interactive menu lets you pick what to install. Everything symlinks to `~/.claude/` — updates are instant via `eagle-skills update`.

## Skills

Invoked via slash commands in Claude Code.

| Skill | Command | What it does |
|-------|---------|-------------|
| [UX Review](docs/skills/ux-review.md) | `/eagle-ux-review` | Expert UX audits grounded in 65+ UX laws, with HTML/Word reports |
| [Product Diagnostics](docs/skills/product-diagnostics.md) | `/eagle-product-diagnostics` | Three-layer data validation: design intent + behavior + outcomes |
| [Ad Review](docs/skills/ad-review.md) | `/eagle-ad-review` | Strategy-first ad creative review across any medium |
| [Anti-Slop](docs/skills/anti-slop.md) | `/eagle-anti-slop` | Detect and eliminate AI-generated slop in code, text, and design |
| [Clean Doc](docs/skills/clean-doc.md) | `/eagle-clean-doc` | Modern Word documents — Helvetica, monochrome, clean |
| [Clean Sheet](docs/skills/clean-sheet.md) | `/eagle-clean-sheet` | Modern Excel spreadsheets — consistent styling, frozen headers |
| [Multi-Stack Scaffolder](docs/skills/multi-stack-scaffolder.md) | `/eagle-multi-stack-scaffolder` | Research-driven project scaffolding for 13+ stacks |
| [CLAUDE.md](docs/skills/claude-md.md) | `/eagle-claude-md` | Lean project CLAUDE.md + LLM Wiki + Obsidian vault integration |
| [Bootstrap](docs/skills/bootstrap.md) | `/eagle-bootstrap` | One-time global setup: behavioral rules, hooks, vault config |
| [Feature Flow](docs/skills/feature-flow.md) | `/eagle-feature-flow` | Structured dev workflow: plan, build, test, review, anti-slop, commit |
| [Compact Add](docs/skills/compact-add.md) | `/eagle-compact-add` | Review and add new rules to the compact token saver |

## Agents

Dispatched by Claude's Agent tool. Ask Claude to run one by name, or describe what you need — Claude picks the right specialist.

| Agent | Category | What it does |
|-------|----------|-------------|
| [Spectral Plan](docs/agents.md#eagle-spectral-plan) | lifecycle | Scopes features, evaluates approaches, produces implementation plans |
| [Spectral Investigate](docs/agents.md#eagle-spectral-investigate) | lifecycle | Root-cause debugging — traces code paths, tests hypotheses, fixes |
| [Spectral Ship](docs/agents.md#eagle-spectral-ship) | lifecycle | Pre-ship pipeline — build/test/lint gates, diff review, PR creation |
| [Security Audit](docs/agents.md#eagle-security-audit) | review | Vulnerability hunting — injection, auth, data exposure, supply chain |
| [Architecture Review](docs/agents.md#eagle-architecture-review) | review | Structural health — dependencies, coupling, cohesion, patterns |
| [Performance Review](docs/agents.md#eagle-performance-review) | review | Bottleneck analysis — memory leaks, N+1 queries, bundle bloat |
| [Code Quality](docs/agents.md#eagle-code-quality) | review | Readability, dead code, duplication, convention violations, test gaps |
| [UX Code Review](docs/agents.md#eagle-ux-code-review) | review | Frontend UX — loading states, error handling, form validation |
| [Accessibility Review](docs/agents.md#eagle-accessibility-review) | review | WCAG 2.1 AA — semantic HTML, ARIA, keyboard nav, contrast |
| [API Review](docs/agents.md#eagle-api-review) | review | Endpoint consistency, contracts, error handling, versioning |
| [Data Integrity](docs/agents.md#eagle-data-integrity) | review | Race conditions, partial writes, missing transactions |
| [Database Review](docs/agents.md#eagle-database-review) | review | Schema design, query performance, migrations, indexes |

## CLI

```bash
eagle-skills install      # Interactive installer
eagle-skills update       # Pull latest (symlinks update in place)
eagle-skills status       # Show installed items, check for updates
eagle-skills usage        # Show inputs, outputs, and examples
eagle-skills uninstall    # Remove everything
```

## Docs

| Topic | Link |
|-------|------|
| Installation guide | [docs/installation.md](docs/installation.md) |
| All agents reference | [docs/agents.md](docs/agents.md) |
| Compact hook system (token saver) | [docs/compact-hook.md](docs/compact-hook.md) |
| The three-skill pipeline | [docs/pipeline.md](docs/pipeline.md) |
| UX Review methodology | [docs/ux-review-methodology.md](docs/ux-review-methodology.md) |
| Product Diagnostics methodology | [docs/product-diagnostics-methodology.md](docs/product-diagnostics-methodology.md) |
| Ad Review methodology | [docs/ad-review-methodology.md](docs/ad-review-methodology.md) |

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- `ffmpeg` — required for video input in UX Review and Ad Review (`brew install ffmpeg`)
- `imagemagick` — optional, for Ad Review thumbnail generation (`brew install imagemagick`)

## License

MIT
