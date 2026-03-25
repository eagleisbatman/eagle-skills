# Database Outcome Template

Provide actual outcome data so we can validate whether product goals are being achieved. This is "ground truth" — what actually happened, regardless of what the UX looks like or what events say.

---

## Database / Data Source

**Source:** [e.g., PostgreSQL, BigQuery, Firebase Realtime DB, Supabase, MongoDB, spreadsheet]
**Date range:** [e.g., 2026-01-01 to 2026-03-25]
**Sample size:** [e.g., 12,400 users]
**How extracted:** [e.g., SQL query, admin dashboard export, manual count]

---

## Outcome Metrics

For each feature/goal in your goal definition, provide the actual measured outcome.

### Feature: [Feature Name — must match goal-definition.md]

| Metric | Target | Actual | Sample Size | Confidence |
|--------|--------|--------|-------------|-----------|
| [e.g., queries per user per session] | [3+] | [1.1] | [8,200 sessions] | [High — large sample] |
| [e.g., D7 retention] | [20%] | [8%] | [3,400 cohort] | [High] |
| [e.g., task completion rate] | [70%] | [35%] | [1,200 attempts] | [Medium — 4 weeks data] |

**Data source / query:**
```sql
-- Paste the SQL query or describe how you got these numbers
SELECT
  COUNT(DISTINCT user_id) as users,
  AVG(queries_per_session) as avg_queries,
  AVG(CASE WHEN returned_day_7 THEN 1 ELSE 0 END) as d7_retention
FROM user_metrics
WHERE signup_date BETWEEN '2026-01-01' AND '2026-03-25';
```

*(Or: "Exported from admin dashboard > Analytics > Retention tab")*

---

## Cohort Comparison (High Value — Provide If Possible)

The most powerful analysis compares users who experienced a specific UX condition vs. those who didn't.

### Cohort: [Description — e.g., "Users who hit mode selection gate vs. direct-to-chat"]

| Metric | Cohort A: [e.g., Hit mode gate] | Cohort B: [e.g., Direct to chat] | Difference |
|--------|------|------|------------|
| Sample size | [n] | [n] | -- |
| Queries per session | [X] | [Y] | [+/-Z%] |
| D7 retention | [X%] | [Y%] | [+/-Z pp] |
| Session duration | [Xs] | [Ys] | [+/-Zs] |
| Revenue per user | [$X] | [$Y] | [+/-$Z] |

**How cohorts were defined:**
```sql
-- Example: users who viewed mode_select screen vs those who went directly to chat
-- Cohort A: EXISTS (SELECT 1 FROM events WHERE event = 'screen_view' AND screen = 'mode_select' AND user_id = u.id)
-- Cohort B: NOT EXISTS (...)
```

---

## User-Level Sample (Optional)

If available, provide a sample of individual user journeys. This helps identify patterns.

| User ID | Signup Date | Total Sessions | Total Queries | D7 Return | D30 Return | Last Active |
|---------|-----------|---------------|--------------|-----------|-----------|-------------|
| u_001 | 2026-01-15 | 1 | 0 | No | No | 2026-01-15 |
| u_002 | 2026-01-15 | 3 | 5 | Yes | No | 2026-01-22 |
| u_003 | 2026-01-16 | 12 | 34 | Yes | Yes | 2026-03-20 |

---

## What If You Don't Have a Database?

Provide whatever ground truth you have:

- **Spreadsheet export** — from any admin panel or dashboard
- **Manual counts** — "We have ~500 active users, about 50 use the chat feature"
- **Revenue numbers** — "Monthly revenue was $X before feature launch, $Y after"
- **Support volume** — "We get ~30 tickets/week about this feature"
- **App store reviews** — star rating trend, common complaints

Any real-world outcome data helps, even if approximate.

---

## Tips

- **Match feature names** to your goal definition template — this is how findings get connected.
- **Include sample sizes.** A "35% completion rate" from 50 users is very different from 50,000 users.
- **Provide cohort comparisons if possible.** This is the single most valuable data input. It lets us say "users who experienced X have 3x better retention than users who didn't."
- **Don't clean the data too much.** Raw numbers with context are better than curated summaries that hide the variance.
- **Include the query/source.** This lets us verify the numbers make sense and suggest refinements.
