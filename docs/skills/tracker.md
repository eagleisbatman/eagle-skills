# Eagle Tracker

Project trackers and Gantt charts as `.xlsx` files that open in Excel and import
cleanly into Google Sheets.

## Command

```
/eagle-tracker
```

Also triggers on: "project tracker", "task tracker", "gantt chart", "project plan", "roadmap", "timeline", "sprint board", "raid log", "track tasks with owners and dates"

## What you get

A three-sheet workbook from a simple JSON spec (`scripts/build_tracker.py`):

- **Tracker** — task table with a Status dropdown (data validation), status-tinted rows, a `% Complete` data bar, and a live `Duration` formula.
- **Gantt** — a conditional-formatting cell grid (no macros, no chart object), bars colored by status, with a today marker. Survives the Excel ↔ Google Sheets round-trip.
- **Dashboard** — total tasks, duration-weighted % complete, overdue count.

`--timescale day|week|month` sets granularity. `--sheets-native` adds a SPARKLINE
bar column (Sheets-only; `#NAME?` in Excel).

## Design system

Built on Eagle Clean Sheet (Helvetica, monochrome, gray borders) plus a small
**functional** status palette (Not started / In progress / Blocked / On hold /
Done / Milestone) — color carries RAG meaning, which the clean-sheet rule allows.

## Usage

Give it a list of tasks with owners, start/end dates, and status (prose, CSV,
JSON, or a JSON spec). It builds the spec, generates the workbook, and you import
it into Google Sheets via Drive → Open with Google Sheets.

## Example

```
You: Turn this list of tasks, owners, and dates into a project tracker with a Gantt chart for Google Sheets
```
