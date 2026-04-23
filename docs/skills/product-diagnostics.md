# Eagle Product Diagnostics

Data-validated product analysis using three-layer triangulation: design intent, instrumented behavior, and outcome truth.

## What it does

Takes your actual data — analytics events and database outcomes — and validates each UX finding against reality. The result is not "we think this is broken" but "this IS broken, here's the funnel that proves it, and here's how much it costs."

## Command

```
/eagle-product-diagnostics
```

Also triggers on: "validate these findings", "product diagnostics", "funnel analysis", "why isn't this metric moving", "triangulate UX and data"

## Required inputs

- Goal definitions (success metrics per feature)
- Event taxonomy (analytics events mapped to screens and funnels)
- Database outcomes (actual vs. target metrics)

## Optional inputs

- A UX review report (from Eagle UX Review) for per-finding validation

## Output

HTML, Word, and/or Excel report with:
- Goal scorecard (PASS/FAIL/PARTIAL per layer)
- Funnel visualizations with drop-off analysis
- Per-feature three-layer diagnosis
- Disagreement analysis
- Business impact estimates
- Prioritized actions

## Example session

```
You:   Why isn't our onboarding completion rate improving? Here's our Firebase
       events export and the DB metrics.
Claude: [asks for goal definitions, event-to-screen mapping, target metrics]
You:   [provides event taxonomy CSV, DB query results, and links the UX review]
Claude: [triangulates design intent vs. behavior vs. outcomes, generates report]
```

## How it works

Triangulates three independent evidence sources — design intent (UX review predictions), instrumented behavior (analytics events), and outcome truth (database metrics). Eight verdict patterns diagnose whether issues are UX problems, measurement gaps, value proposition failures, or something else entirely.

[Read the full methodology →](../product-diagnostics-methodology.md)
