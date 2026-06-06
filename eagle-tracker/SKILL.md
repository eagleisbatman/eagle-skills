---
name: eagle-tracker
description: "Use this skill to create project trackers, task lists, roadmaps, and Gantt charts as .xlsx files that open in Excel AND import cleanly into Google Sheets. Triggers on: 'project tracker', 'task tracker', 'create a Gantt chart', 'project plan', 'roadmap', 'timeline', 'sprint board', 'RAID log', 'who's doing what by when', 'track tasks with owners and dates', 'turn this into a tracker', or when the user lists tasks/owners/dates and wants them organized into a trackable, shareable sheet. Produces status dropdowns, status-colored Gantt bars, computed duration/%-complete, a today marker, and a small dashboard. Composes with eagle-clean-sheet styling. Do NOT use for ad-hoc data tables with no time/ownership dimension (use eagle-clean-sheet directly), or for live Google Sheets API integration."
---

# Eagle Tracker — Project Trackers & Gantt Charts for Excel + Google Sheets

Turns a list of tasks (owners, dates, status) into a styled, shareable workbook
that works in **both** Excel and Google Sheets — no macros, no native chart
objects, so nothing breaks on import. Built on the `eagle-clean-sheet` design
language.

## When to use

The user has work to track over time with owners and dates: a delivery plan, a
component build list, a sprint, a release roadmap, a migration checklist. If
there is no time or ownership dimension, it is just a table — use
`eagle-clean-sheet` instead.

## How it works

A Python engine, `scripts/build_tracker.py`, takes a JSON spec and emits a
three-sheet workbook. Prefer the engine over hand-rolling openpyxl — it gets the
conditional-formatting Gantt formulas, date coercion, and data validation right
every time.

```bash
python scripts/build_tracker.py spec.json -o tracker.xlsx --timescale week
```

`--timescale day|week|month` sets the Gantt granularity (default `week`).
`--sheets-native` adds a SPARKLINE bar column (renders in Sheets; shows `#NAME?`
in Excel — opt-in only).

### The spec

See `assets/example-spec.json`. Minimum per task: `task`, `owner`, `status`,
`start`, `end` (dates as `YYYY-MM-DD`). Optional: `group`, `percent` (0–100).
Top level: `title`, `timescale`, `statuses` (the dropdown list).

### What you get

1. **Tracker** — the task table. Status column is a **dropdown** (data
   validation), rows are tinted by status, `% Complete` shows a data bar, and
   `Duration` is a live formula. Sort/filter friendly.
2. **Gantt** — a conditional-formatting **cell grid**: each task's bar is drawn
   by a formula that fills bucket cells between Start and End, colored by status.
   A **today marker** highlights the current period on the header row. This is
   the portable Gantt — it survives the Excel ↔ Google Sheets round-trip.
3. **Dashboard** — three live rollups: total tasks, duration-weighted %
   complete, and overdue count.

## Building the spec from a conversation

When the user describes work in prose or pastes a list, extract one task per
line: name, owner, status, start, end. Infer sensible dates from stated
milestones ("ready by the 20th" → end date) and ask only if a date is genuinely
unknowable. Group related tasks with the `group` field so the Gantt reads in
phases.

## Design note — status color is intentional

The base `eagle-clean-sheet` system is monochrome, but this skill keeps a small
**functional** status palette (Not started / In progress / Blocked / On hold /
Done, plus Milestone). Color here carries meaning (RAG signal), which the
clean-sheet rule explicitly allows. Do not strip it when applying clean-sheet
styling on top.

## Tracker types

The engine covers task/Gantt trackers directly. For other shapes (roadmap,
sprint/kanban, RAID log, dependency matrix), see `references/tracker-types.md` —
each maps onto the same spec with a different `group`/`status` convention.

## References

- `references/tracker-types.md` — playbook for each tracker shape.
- `references/gantt-recipes.md` — the CF-grid and SPARKLINE Gantt formulas, plus
  how to build one by hand if the engine is unavailable.
- `references/sheets-compatibility.md` — what survives the xlsx → Google Sheets
  import, the import steps, and known gotchas.

## Verify before delivering

Always open the output and confirm the Gantt bars render. If portability matters
to the user, do the round-trip: open in Excel, then drag into Google Drive →
Open with Google Sheets, and confirm the bars + dropdowns survive.
