# Tracker types

All of these map onto the same `build_tracker.py` spec — they differ only in how
you use `group`, `status`, and `timescale`. Pick the shape that fits the work.

## 1. Task / delivery tracker (default)
One row per task with owner, dates, status, % complete. `group` = phase or
workstream. The default Gantt + dashboard answer "who is doing what by when, and
are we on track."

## 2. Roadmap
Coarser tasks, `--timescale month`, `group` = theme or quarter. Each row is an
initiative spanning weeks/months. Use Milestone status for launch dates.

## 3. Sprint / kanban
`status` becomes the board column: `Backlog, To do, In progress, Review, Done`.
Pass these as the spec's `statuses` so the dropdown matches. `group` = epic.
`--timescale day` for a two-week sprint.

## 4. Milestone tracker
Tasks with `start == end` and status `Milestone` render as single-period markers.
Mix milestones with normal bars to show deliverables against a timeline.

## 5. RAID log (Risks, Assumptions, Issues, Dependencies)
`group` = R / A / I / D. `status` = `Open, Mitigating, Closed`. Dates = raised /
target-resolution. The Gantt then shows how long items stay open.

## 6. Dependency view
Add a `depends_on` note in the task name or a Group, and order tasks so
predecessors sort above successors. (The engine does not draw arrows — Excel/
Sheets can't render dependency arrows portably — so encode dependencies as
ordering + a note, or split into phases via `group`.)

## Choosing a timescale
- `day` — sprints, launches, anything under ~6 weeks. One column per day.
- `week` — most delivery plans (default). One column per week (Monday-anchored).
- `month` — roadmaps and multi-quarter plans. One column per month.

Keep the total bucket count reasonable (< ~60 columns) so the Gantt stays
readable and the file imports quickly into Sheets.
