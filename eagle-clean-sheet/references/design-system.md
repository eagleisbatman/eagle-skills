# Eagle Clean Sheet — Design System Reference

Same design language as Eagle Clean Doc, applied to Excel via openpyxl.

## Fonts

| Role | openpyxl | Name | Size | Color |
|------|----------|------|------|-------|
| Body | `FONT_BODY` | Helvetica | 10.5 | 000000 |
| Header | `FONT_HEADER` | Helvetica Bold | 10 | 000000 |
| Title | `FONT_TITLE` | Helvetica Bold | 14 | 000000 |
| Subtitle | `FONT_SUBTITLE` | Helvetica Bold | 11 | 000000 |
| Code | `FONT_CODE` | Courier New | 9.5 | 000000 |
| Caption | `FONT_CAPTION` | Helvetica | 8.5 | 6B7280 |

## Fills

| Role | openpyxl | Color |
|------|----------|-------|
| Header row | `FILL_HEADER` | F3F4F6 |
| Alt row | `FILL_ALT_ROW` | F9FAFB |
| Code cell | `FILL_CODE` | F3F4F6 |
| Default | `FILL_WHITE` | FFFFFF |

## Borders

```python
THIN_GRAY = Side(style='thin', color='D1D5DB')
BORDER_ALL = Border(top=THIN_GRAY, bottom=THIN_GRAY, left=THIN_GRAY, right=THIN_GRAY)
BORDER_BOTTOM = Border(bottom=THIN_GRAY)
```

## Layout

- Freeze header row: `sheet.freeze_panes = 'A4'` (or wherever data starts)
- Title in row 1 (merged), spacer row 2, headers row 3, data from row 4
- Column widths: calculate from content, cap at 50
- Row height: 24 title, 8 spacer, 22 header, default for data

## When to use code font

Courier New + F3F4F6 fill for: API endpoints, file paths, formula references, technical identifiers, environment variables, config keys, code snippets, event names, metric identifiers.

## Financial models

Base xlsx skill color conventions override this system for financial models (blue inputs, black formulas, green cross-sheet links). Clean Sheet applies to: fonts, borders, fills, alignment, widths.

## Verdict Styling (for Eagle Review Skills)

For PASS/FAIL/PARTIAL verdicts in scorecard exports:
- **PASS**: Bold, regular black text
- **FAIL**: Bold, regular black text
- **PARTIAL**: Bold, regular black text

All monochrome — no color coding for verdicts. The text itself communicates the status.
