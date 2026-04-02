---
name: eagle-clean-sheet
description: "ALWAYS use this skill instead of the default xlsx skill whenever creating, editing, or manipulating spreadsheet files (.xlsx, .xlsm, .csv, .tsv). This skill applies the Clean Doc design system to Excel outputs — Helvetica body, Courier New for code/formulas, monochrome palette, clean table styling. Triggers on: any spreadsheet task including creating, reading, editing, formatting, charting, cleaning data, or converting tabular formats. Also use when eagle-product-diagnostics or eagle-ad-review needs to export structured data (scorecards, funnels, findings) to Excel. Do NOT use for Word documents, PDFs, or Google Sheets API integrations."
---

# Eagle Clean Sheet — Modern XLSX Design System

Wraps the base xlsx skill with the Clean Doc design language. Read this for visual defaults, then `/mnt/skills/public/xlsx/SKILL.md` for all technical patterns (openpyxl, pandas, formulas, recalculation, validation).

---

## Design Philosophy

Same principles as Eagle Clean Doc: **clean, monochrome, compact, zero noise.**

- **Helvetica** for all cell text. Falls back to Arial.
- **Courier New** for cells containing formulas, code, file paths, or technical identifiers.
- **Monochrome**: Black text, white background, gray accents. Minimal color — only for functional meaning.
- **No default headers/footers**: Ask the user before adding print headers/footers.

---

## openpyxl Style Definitions

```python
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side, numbers

# === FONTS ===
FONT_BODY = Font(name='Helvetica', size=10.5, color='000000')
FONT_HEADER = Font(name='Helvetica', size=10, color='000000', bold=True)
FONT_TITLE = Font(name='Helvetica', size=14, color='000000', bold=True)
FONT_SUBTITLE = Font(name='Helvetica', size=11, color='000000', bold=True)
FONT_CODE = Font(name='Courier New', size=9.5, color='000000')
FONT_CAPTION = Font(name='Helvetica', size=8.5, color='6B7280')

# === FILLS ===
FILL_HEADER = PatternFill(start_color='F3F4F6', end_color='F3F4F6', fill_type='solid')
FILL_ALT_ROW = PatternFill(start_color='F9FAFB', end_color='F9FAFB', fill_type='solid')
FILL_WHITE = PatternFill(start_color='FFFFFF', end_color='FFFFFF', fill_type='solid')
FILL_CODE = PatternFill(start_color='F3F4F6', end_color='F3F4F6', fill_type='solid')
# No other fill colors. No yellow, no blue, no green backgrounds.

# === BORDERS ===
THIN_GRAY = Side(style='thin', color='D1D5DB')
BORDER_ALL = Border(top=THIN_GRAY, bottom=THIN_GRAY, left=THIN_GRAY, right=THIN_GRAY)
BORDER_BOTTOM = Border(bottom=THIN_GRAY)  # For minimal/ruled style

# === ALIGNMENT ===
ALIGN_LEFT = Alignment(horizontal='left', vertical='center', wrap_text=True)
ALIGN_RIGHT = Alignment(horizontal='right', vertical='center')
ALIGN_CENTER = Alignment(horizontal='center', vertical='center')
ALIGN_HEADER = Alignment(horizontal='left', vertical='center', wrap_text=True)
```

## Applying Styles

### Sheet Title Row

```python
# Row 1: Title spanning merged cells
sheet.merge_cells('A1:F1')
title_cell = sheet['A1']
title_cell.value = "API Endpoints"
title_cell.font = FONT_TITLE
title_cell.alignment = ALIGN_LEFT
# Leave row 2 empty as spacing, data starts row 3
```

### Header Row

```python
headers = ['Method', 'Endpoint', 'Description', 'Auth']
for col, header in enumerate(headers, 1):
    cell = sheet.cell(row=3, column=col, value=header)
    cell.font = FONT_HEADER
    cell.fill = FILL_HEADER
    cell.border = BORDER_ALL
    cell.alignment = ALIGN_HEADER
```

### Data Rows

```python
for row_idx, row_data in enumerate(data, start=4):
    for col_idx, value in enumerate(row_data, 1):
        cell = sheet.cell(row=row_idx, column=col_idx, value=value)
        cell.font = FONT_BODY
        cell.border = BORDER_ALL
        cell.alignment = ALIGN_LEFT
        cell.fill = FILL_WHITE
        # Alternating rows for large datasets (20+ rows):
        # if row_idx % 2 == 0: cell.fill = FILL_ALT_ROW
```

### Code/Technical Columns

For columns containing endpoints, formulas, file paths, identifiers:

```python
cell.font = FONT_CODE
cell.fill = FILL_CODE  # subtle gray background
cell.alignment = ALIGN_LEFT
```

### Column Widths

```python
# Auto-fit is not available in openpyxl — set sensible defaults
sheet.column_dimensions['A'].width = 12   # Short labels
sheet.column_dimensions['B'].width = 28   # Endpoints, descriptions
sheet.column_dimensions['C'].width = 28   # Descriptions
sheet.column_dimensions['D'].width = 14   # Short values

# Or calculate from content:
for col in sheet.columns:
    max_len = max(len(str(cell.value or '')) for cell in col)
    adjusted = min(max_len + 3, 50)  # cap at 50
    sheet.column_dimensions[col[0].column_letter].width = adjusted
```

### Row Heights

```python
sheet.row_dimensions[1].height = 24   # Title row
sheet.row_dimensions[2].height = 8    # Spacer
sheet.row_dimensions[3].height = 22   # Header row
# Data rows: default (15) is fine, or set 18 for breathing room
```

### Freeze Panes

```python
sheet.freeze_panes = 'A4'  # Freeze header row (if data starts at row 4)
```

---

## Color Tokens (same as Eagle Clean Doc)

| Token | Hex | Use |
|-------|-----|-----|
| Black | `000000` | All body text, headers, code text |
| Charcoal | `1F2937` | Subtitle text (optional) |
| Gray 500 | `6B7280` | Captions, sheet tab descriptions |
| Gray 300 | `D1D5DB` | All borders |
| Gray 100 | `F3F4F6` | Header row fill, code cell fill |
| Gray 50 | `F9FAFB` | Alternating row fill (large tables) |
| White | `FFFFFF` | Default cell fill |
| Blue 600 | `2563EB` | Hyperlinks only |

---

## Financial Model Exception

For financial models, the base xlsx skill's color coding conventions (blue inputs, black formulas, green cross-sheet links) **override** this design system. Financial model color coding is an industry standard and must be preserved. The Clean Sheet design system applies to everything else: fonts, borders, fills, alignment, column widths.

---

## Integration with Eagle Review Skills

When generating Excel exports for eagle-product-diagnostics or eagle-ad-review:

### Goal Scorecard Sheet
- Title: "Goal Scorecard"
- Headers: Feature, Design Intent, Behavior, Outcome, Overall Verdict
- PASS/FAIL/PARTIAL as text values (bold)
- Use FONT_CODE for event names and metric identifiers

### Funnel Analysis Sheet
- Title: "Funnel Analysis"
- Headers: Step, Event Name, Users, Conversion (%), Drop-off (%)
- Event names in FONT_CODE
- Percentages right-aligned with ALIGN_RIGHT
- Drop-off > 30% in bold

### Findings Sheet
- Title: "Findings"
- Headers: #, Severity, Finding, UX Law, North Star Impact, Recommendation
- Severity column: bold text
- One row per finding

### Ad Scoring Sheet (for eagle-ad-review)
- Title: "Creative Scores"
- Headers: Creative, Overall, Hook, Message Clarity, Brand Presence, CTA, Platform Fit, ...
- Scores as numbers (0-10), right-aligned
- Creative filenames in FONT_CODE

---

## What This Skill Does NOT Override

Everything from the base xlsx skill: openpyxl/pandas patterns, formula construction, recalculation (`scripts/recalc.py`), formula verification, error prevention, number formatting standards, library selection guidance, and code style guidelines.

**For ALL of the above, defer to `/mnt/skills/public/xlsx/SKILL.md`.**
