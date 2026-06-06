# Gantt recipes

Two ways to draw a Gantt that works in Excel and Google Sheets. The engine uses
recipe A by default. Recipe B is opt-in (`--sheets-native`) for Sheets-first use.

## Recipe A — conditional-formatting cell grid (portable, default)

A timeline header row of period-start dates, and a grid of empty cells. One CF
rule per status fills a cell when its bucket overlaps the task's [Start, End].

Layout (engine): leading columns `Task | Owner | Start | End | Status`, then one
column per period from column F. Headers (real dates) on row 3, tasks from row 4.

Overlap test for a task vs a bucket: `start <= bucketEnd AND end >= bucketStart`.

CF formula applied to the grid `F4:<last>`, anchored at F4 (per status):
```
week:  =AND($E4="In progress", $C4<=F$3+6,          $D4>=F$3)
day:   =AND($E4="In progress", $C4<=F$3,            $D4>=F$3)
month: =AND($E4="In progress", $C4<=EOMONTH(F$3,0), $D4>=F$3)
```
- `$E4` status (abs column, rel row) · `$C4`/`$D4` start/end · `F$3` bucket start
  (rel column, abs row 3). Excel and Sheets both adjust the relative parts across
  the range.

Today marker on the header row `F3:<last>3`:
```
week: =AND(F3<=TODAY(), TODAY()<=F3+6)
```

Critical: Start/End/header cells must be **real dates**, not text. A text date
makes every comparison silently false and no bar appears. The engine coerces and
fails loudly; if hand-building, format the cells as dates and verify with
`=ISNUMBER(F3)`.

Keep the bar grid **unmerged and uniform** — merged cells make CF ranges behave
differently between Excel and Sheets.

## Recipe B — SPARKLINE bar (Google Sheets native, opt-in)

A single cell per task renders a horizontal bar with `=SPARKLINE`:
```
=SPARKLINE({offset, duration}, {"charttype","bar"; "max",TOTAL_DAYS;
           "color1","white"; "color2","#F59E0B"})
```
- `offset` = days from project start to task start (the white spacer)
- `duration` = task length in days (the colored bar)
- `max` = total project span

Color by status with IFS:
```
=SPARKLINE({offset,duration},{"charttype","bar";"max",TOTAL;"color1","white";
  "color2", IFS(E4="Done","#10B981",E4="Blocked","#EF4444",
               E4="In progress","#F59E0B", TRUE,"#D1D5DB")})
```

SPARKLINE is a Google Sheets function. In Excel these cells show `#NAME?`. Use
Recipe B only when the deliverable lives in Sheets.

## Milestones

Render as a task with `start == end` and status `Milestone` (dark marker). To
make it a diamond in Sheets, a separate single-cell `=SPARKLINE` with a tiny
duration reads as a marker; in the CF grid it is a single filled cell.

## Why no native chart object

Excel's stacked-bar Gantt (made-invisible first series) does not survive import
to Google Sheets — the series config is dropped. The CF cell grid is the only
approach that renders identically in both, which is why it is the default.
