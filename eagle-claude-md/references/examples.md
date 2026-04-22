# Example Project CLAUDE.md Files

These examples show the target output — lean, project-specific, no global duplication.

## Example 1: Node.js API

```markdown
## invoice-api

REST API for invoice generation and payment tracking.

## Stack

TypeScript, Express, Drizzle ORM, PostgreSQL, Railway

## Commands

| Command | What it does |
|---------|-------------|
| `bun test` | Run Vitest suite |
| `bun run lint` | ESLint + Prettier check |
| `bun run build` | Compile to dist/ |
| `bun run dev` | Start with watch mode (port 3001) |
| `bun run db:push` | Push schema changes to database |
| `bun run db:studio` | Open Drizzle Studio |

## Architecture

- Routes in `src/routes/`, one file per resource (invoices.ts, payments.ts, webhooks.ts)
- Business logic in `src/services/`, never in route handlers
- Database schema in `src/db/schema.ts` — single file, Drizzle manages migrations
- Stripe webhooks verified via `src/middleware/stripe-verify.ts` before reaching handlers
- PDF generation uses Puppeteer with templates in `src/templates/`

## Conventions

- All monetary values stored as integers (cents), converted to display format only in response serialization
- Dates stored as UTC timestamps, formatted per user locale in the response layer
```

## Example 2: Swift iOS App

```markdown
## HeadSpace

Meditation and journaling iOS app.

## Stack

SwiftUI, SwiftData, CloudKit, SPM

## Commands

| Command | What it does |
|---------|-------------|
| `swift test` | Run unit tests |
| `swift build` | Build the package |

## Architecture

- MVVM with `@Observable` view models (no Combine)
- SwiftData for local persistence, CloudKit sync via `ModelConfiguration`
- Navigation via `NavigationStack` with typed `NavigationPath` — no coordinators
- Audio playback through a single `AudioEngine` actor (not a manager class)
- All network calls go through `APIClient` which handles auth token refresh

## Conventions

- Views named `<Thing>View`, view models named `<Thing>ViewModel` — colocated in same file if under 100 lines
- Feature modules in `Sources/Features/<Name>/` with View + ViewModel + optional Model
- Colors and fonts defined in `Sources/Design/Tokens.swift`, never hardcoded in views
```

## Example 3: Python Data Pipeline

```markdown
## etl-pipeline

Nightly ETL pipeline for warehouse data ingestion.

## Stack

Python 3.12, SQLAlchemy, Celery, Redis, PostgreSQL

## Commands

| Command | What it does |
|---------|-------------|
| `uv run pytest` | Run test suite |
| `uv run ruff check .` | Lint |
| `uv run celery -A pipeline worker` | Start worker |
| `uv run python -m pipeline.cli run` | Manual pipeline trigger |

## Architecture

- Pipeline stages in `pipeline/stages/` — each is a Celery task, chained via `pipeline/orchestrator.py`
- Raw data lands in `staging` schema, transforms write to `warehouse` schema
- Idempotent: every stage can be re-run safely (upsert on natural keys)
- Secrets from environment variables only, never config files

## Active Constraints

- Must complete nightly run within 2-hour window (00:00–02:00 UTC)
- Source API rate-limited to 100 req/min — backoff logic in `pipeline/client.py`
- PostgreSQL 15 minimum (uses MERGE statement)
```

## Anti-patterns (what NOT to generate)

```markdown
## My Project

This is a project that uses modern best practices...

## Getting Started

First, clone the repository...

## Code Quality

We follow clean code principles. Use meaningful variable names...

## Deployment

Push to GitHub and Railway will auto-deploy...

## Testing

Write tests for all new features...
```

Every line above is either generic advice (belongs nowhere) or a global rule (belongs in ~/.claude/CLAUDE.md). A project CLAUDE.md with this content is worse than no CLAUDE.md.
