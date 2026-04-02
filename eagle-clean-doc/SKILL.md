---
name: eagle-clean-doc
description: "ALWAYS use this skill instead of the default docx skill whenever creating, editing, or manipulating Word documents (.docx files). This skill applies a modern, clean, monochrome design system — Helvetica body, Courier New for code, tight margins, inline code spans, proper multi-line code blocks, clean tables, and zero visual clutter. Triggers on: 'Word doc', '.docx', reports, memos, letters, templates, or any Word deliverable. Also use when eagle-ux-review, eagle-product-diagnostics, or eagle-ad-review output format is set to Word or both. Do NOT use for PDFs, spreadsheets, or Google Docs."
---

# Eagle Clean Doc — Modern DOCX Design System

Wraps the base docx skill with a modern design system. Read this for visual defaults, then `/mnt/skills/public/docx/SKILL.md` for all technical patterns. Read `references/design-system.md` before writing any docx-js code.

A sample document demonstrating this design system is at `assets/modern-design-sample-v6.docx`.

---

## Design Philosophy

**Clean. Monochrome. Compact. Zero noise.**

- **Helvetica** for body and headings. Falls back to Arial.
- **Courier New** for all code — inline spans and multi-line blocks. Pure black text for maximum readability.
- **Monochrome only**: Black text, white background, gray accents. No colored headings or decorative fills.
- **Compact margins**: 0.4" top/bottom, 0.5" sides. Content width = 10800 DXA.
- **No default headers/footers**: Always ask the user before adding them.

---

## Page Setup

```javascript
margin: { top: 576, bottom: 576, left: 720, right: 720 }
// Content width = 12240 - 720 - 720 = 10800 DXA
```

## Typography

```javascript
const FONT = { body: "Helvetica", heading: "Helvetica", mono: "Courier New" };

// Document default: 10.5pt Helvetica, 1.1x line height
run: { font: FONT.body, size: 21, color: "000000" }
paragraph: { spacing: { after: 120, line: 264 } }

// Headings: all Helvetica, bold, black
// H1: 36 (18pt), before: 240, after: 80
// H2: 28 (14pt), before: 200, after: 60
// H3: 24 (12pt), before: 160, after: 50, color: "1F2937"
```

## Inline Code Spans

When mentioning function names, endpoints, variables, config keys, class names, CLI commands, file paths, or any code-like text within a paragraph — render in Courier New with gray background and **black text**:

```javascript
function code(text) {
  return new TextRun({
    text: ` ${text} `,
    font: "Courier New", size: 19, color: "000000",
    shading: { type: "clear", fill: "F3F4F6" },
  });
}

// Usage:
new Paragraph({ children: [
  new TextRun({ text: "Initialize with ", font: "Helvetica", size: 21 }),
  code("EcoFarmerAI.initialize()"),
  new TextRun({ text: " in your Application class.", font: "Helvetica", size: 21 }),
]})
```

## Multi-line Code Blocks

Single paragraph with `break: 1` TextRuns — preserves indentation, one bordered box. **Black text** for maximum contrast:

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

**Border order**: Must be `top, left, bottom, right` for valid XML.

## Tables

```javascript
const border = { style: BorderStyle.SINGLE, size: 1, color: "D1D5DB" };
const borders = { top: border, bottom: border, left: border, right: border };
// Header: bg "F3F4F6", bold, size 20. Body: bg "FFFFFF", size 21.
// Cell margins: { top: 50-70, bottom: 50-70, left: 100, right: 100 }
// Paragraph in cells: spacing { after: 0, line: 240 }
// Mono columns (endpoints, methods): font "Courier New", size 19, color "000000"
// Full width: 10800 DXA
```

## Lists

```javascript
// Indent: 460/920 with 240 hanging
// Bullets: \u2022 → \u2013 → \u2022
// Numbers: decimal → lower letter → lower roman
```

## Headers/Footers — ASK FIRST

Never add by default. When requested: 8.5pt gray `"6B7280"` Helvetica, thin `"D1D5DB"` rule.

## Color Tokens

| Token | Hex | Use |
|-------|-----|-----|
| Black | `"000000"` | Body, headings, ALL code text |
| Charcoal | `"1F2937"` | H3 headings only |
| Gray 500 | `"6B7280"` | Captions, metadata |
| Gray 300 | `"D1D5DB"` | Borders, rules |
| Gray 100 | `"F3F4F6"` | Table headers, code bg, inline code bg |
| White | `"FFFFFF"` | Backgrounds |
| Blue 600 | `"2563EB"` | Hyperlinks only |

## Dimensions

| Value | DXA | Notes |
|-------|-----|-------|
| Top/bottom margin | 576 | 0.4" |
| Left/right margin | 720 | 0.5" |
| Content width | 10800 | Tables |
| Body | 21 (10.5pt) | Helvetica |
| H1/H2/H3 | 36/28/24 | Bold |
| Code | 19 (9.5pt) | Courier New, black |
| Body line spacing | 264 (1.1x) | |

## Integration with Eagle Review Skills

When generating Word output for eagle-ux-review, eagle-product-diagnostics, or eagle-ad-review:

1. Use the same section structure as the HTML report
2. Embed evidence screenshots as inline images (use `ImageRun` with appropriate sizing)
3. Severity badges become bold text with parenthetical severity: **"(Critical)"**, **"(Major)"**, **"(Minor)"**
4. Score cards become tables with the clean table styling
5. Priority matrices use standard tables
6. Side-by-side mockups become sequential sections ("Current" then "Proposed") with images
7. Save the .docx with the same base name as the HTML (e.g., `ux-review-report.docx` alongside `ux-review-report.html`)

---

**For all technical patterns defer to `/mnt/skills/public/docx/SKILL.md`.**
