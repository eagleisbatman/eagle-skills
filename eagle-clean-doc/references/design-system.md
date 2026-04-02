# Eagle Clean Doc — Design System Reference

Clean, monochrome, compact. Helvetica + Courier New.

## Fonts

| Role | Font | Size | Color |
|------|------|------|-------|
| Body | `"Helvetica"` (fallback: `"Arial"`) | 21 (10.5pt) | `"000000"` |
| H1 | Same | 36 (18pt) bold | `"000000"` |
| H2 | Same | 28 (14pt) bold | `"000000"` |
| H3 | Same | 24 (12pt) bold | `"1F2937"` |
| Code (inline + block) | `"Courier New"` | 19 (9.5pt) | `"000000"` |
| Caption | Same as body | 17 (8.5pt) | `"6B7280"` |

## Colors

| Token | Hex | Usage |
|-------|-----|-------|
| Black | `"000000"` | Body, headings, all code text |
| Charcoal | `"1F2937"` | H3 only |
| Gray 500 | `"6B7280"` | Captions, metadata |
| Gray 300 | `"D1D5DB"` | Borders, rules |
| Gray 100 | `"F3F4F6"` | Table header bg, code bg, inline code bg |
| Gray 50 | `"F9FAFB"` | Alternating rows (large tables) |
| White | `"FFFFFF"` | Backgrounds |
| Blue 600 | `"2563EB"` | Hyperlinks only |

## Layout

```
Margins: top: 576, bottom: 576, left: 720, right: 720
Content width: 10800 DXA
```

## Inline Code

```javascript
new TextRun({
  text: ` functionName() `,
  font: "Courier New", size: 19, color: "000000",
  shading: { type: "clear", fill: "F3F4F6" },
})
```

## Code Blocks

```javascript
function codeBlock(lines) {
  const children = [];
  lines.forEach((line, i) => {
    if (i > 0) children.push(new TextRun({ text: "", break: 1, font: "Courier New", size: 19 }));
    children.push(new TextRun({ text: line || " ", font: "Courier New", size: 19, color: "000000" }));
  });
  return new Paragraph({
    spacing: { before: 80, after: 80, line: 260 },
    shading: { fill: "F3F4F6", type: ShadingType.CLEAR },
    indent: { left: 200, right: 200 },
    border: {
      top: { style: BorderStyle.SINGLE, size: 1, color: "D1D5DB", space: 4 },
      left: { style: BorderStyle.SINGLE, size: 1, color: "D1D5DB", space: 6 },
      bottom: { style: BorderStyle.SINGLE, size: 1, color: "D1D5DB", space: 4 },
      right: { style: BorderStyle.SINGLE, size: 1, color: "D1D5DB", space: 6 },
    },
    children,
  });
}
```

## Tables

```
Border: SINGLE, size: 1, color: "D1D5DB"
Header: bg "F3F4F6", bold, size 20
Body: bg "FFFFFF", normal, size 21
Mono columns: font "Courier New", size 19, color "000000"
Cell margins: { top: 50-70, bottom: 50-70, left: 100, right: 100 }
Cell paragraph: spacing { after: 0, line: 240 }
Full width: 10800 DXA
```

## Lists

```
Indent: 460/920/1620, hanging 240
Bullets: \u2022 → \u2013 → \u2022
Numbers: decimal → lower letter → lower roman
```

## Headers/Footers

Ask user first. Never default. When requested: 8.5pt `"6B7280"` Helvetica, thin `"D1D5DB"` rule.

## Spacing

```
Body: after: 120, line: 264
H1: before: 240, after: 80
H2: before: 200, after: 60
H3: before: 160, after: 50
Code block: before: 80, after: 80, line: 260
Table cells: after: 0, line: 240
```

## Severity Badges (for Eagle Review Skills)

In HTML reports, severity uses colored badges. In Word, use bold parenthetical markers:

- Critical: **`(CRITICAL)`** — Bold, all caps
- Major: **`(MAJOR)`** — Bold, all caps
- Minor: **`(MINOR)`** — Bold, all caps
- Info: **`(INFO)`** — Bold, all caps

These precede the finding title in the same paragraph run.
