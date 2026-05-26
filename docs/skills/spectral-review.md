# Eagle Spectral Review

Route broad Spectral review requests to the right specialist agents.

## Command

```bash
/eagle-spectral-review
```

Also triggers on: "Spectral Agents", "Spectral review", "full spectrum review", "run review specialists", "review this PR with agents", and "choose the right review agents".

## Why this exists

The lifecycle agents have Spectral names:

1. `eagle-spectral-plan`
2. `eagle-spectral-investigate`
3. `eagle-spectral-ship`

Those are useful, but they are not review specialists. Broad requests like "use Spectral Agents" should first route through Eagle Spectral Review or `eagle-spectral-triage`, then pick the right review agents.

## Routing

- Security: `eagle-security-audit`
- Architecture: `eagle-architecture-review`
- Performance: `eagle-performance-review`
- Code quality: `eagle-code-quality`
- Frontend UX: `eagle-ux-code-review`
- Accessibility: `eagle-accessibility-review`
- API contracts: `eagle-api-review`
- Data integrity: `eagle-data-integrity`
- Database: `eagle-database-review`

## Default bundles

1. Backend API: security, API, code quality.
2. Frontend app: UX code review, accessibility, code quality.
3. Database-heavy work: database review, data integrity, performance.
4. Full-stack review: security and code quality, plus the specialists matching the changed files.

Use lifecycle agents only for lifecycle work: planning, debugging, or final shipping.
