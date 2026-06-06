# Google Sheets compatibility

The workbook is built to survive the `.xlsx` → Google Sheets import. This is what
holds, what to avoid, and how to import.

## Importing into Google Sheets
1. Drag the `.xlsx` into Google Drive.
2. Right-click → **Open with → Google Sheets** (this converts it).
   Or, in a Sheet: **File → Import → Upload → Replace/Insert sheets**.
3. Confirm the Gantt bars, status dropdowns, and data bars rendered.

## What survives (used by this skill)
- **Conditional formatting** with formula rules (the Gantt bars, status tints,
  today marker). Converts to Sheets CF.
- **Data validation** dropdowns (the Status column). Becomes a Sheets dropdown.
- **Data bars** for % complete. Converts to a Sheets data-bar-style CF.
- **Formulas**: `AND`, `TODAY`, `EOMONTH`, `SUMPRODUCT`, arithmetic on dates —
  all identical in Sheets.
- **Frozen panes**, number formats, fonts, fills, borders.

## What to avoid (and why the engine doesn't use it)
- **Native Excel chart objects** (stacked-bar Gantt): series config is dropped on
  import. Use the CF cell grid instead.
- **Merged cells inside the bar grid**: CF behaves differently across the two
  apps. Keep the grid uniform.
- **Text dates**: comparisons silently fail. The engine coerces to real dates.
- **Macros / VBA**: do not survive at all.

## SPARKLINE caveat
`--sheets-native` adds `=SPARKLINE(...)` bars. These render in Google Sheets but
show `#NAME?` in Excel (SPARKLINE's bar charttype is Sheets-only). Only use the
flag when the final home is Google Sheets. The default CF-grid Gantt needs no
such tradeoff.

## Fonts
Helvetica falls back to Arial in both apps — visually equivalent. Courier New
(for any code/identifier cells) is available in both.

## Quick self-check after import
- A status dropdown appears in the Status column.
- Changing a status recolors the row and its Gantt bar.
- The current week/day/month column header is highlighted (today marker).
- The Dashboard's weighted % and overdue count are numbers, not `#REF!`.
