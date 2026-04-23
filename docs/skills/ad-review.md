# Eagle Ad Review

Strategy-first advertising creative review grounded in Meta ABCD, Kantar, System1, and Nielsen frameworks. Works across any medium.

## What it does

Evaluates creatives against their marketing job, not just visual aesthetics. An ugly ad that stops the scroll and converts is better than a beautiful ad nobody notices. Works across social, display, video, radio, podcast, billboard, transit, print, TV, and experiential.

## Command

```
/eagle-ad-review
```

Also triggers on: "review these ads", "ad creative review", "audit my ads", "critique these creatives", "ad teardown"

## Required inputs

- Campaign strategy (objective, funnel stage, audience, medium/channels, KPI)
- Brand context (value proposition, positioning, competitive landscape)
- Creative files (images, videos, audio, PDFs, scripts — any format, any medium)

## Output

HTML and/or Word report with:
- 10-dimension scoring (weighted by campaign type and medium)
- Per-creative breakdowns
- Best/worst performer galleries
- Cross-cutting findings with evidence
- Platform compliance audit
- Creative system assessment
- Creative brief for the next production round

## Example session

```
You:   Review these ad creatives — folder is ./ads/. Campaign is awareness for
       rural farmers in UP, running on Meta and local radio.
Claude: [asks for campaign objective, funnel stage, audience details, brand context]
You:   [provides strategy and brand positioning]
Claude: [catalogs all files, scores against Meta ABCD + Kantar + medium-specific
        best practices, generates HTML report]
```

## How it works

Strategy-first 4-step process: gather marketing context, catalog and process all creative files, three-level analysis (strategic fit, execution quality, creative system health), then score and compile. Weights adjust dynamically by campaign type and medium.

[Read the full methodology →](../ad-review-methodology.md)
