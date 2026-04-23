# Eagle UX Review

Expert-level UX audits grounded in 65+ UX laws and principles across 12 categories.

## What it does

Point Claude at a screen recording, screenshots, or a PRD, and receive a structured HTML report: severity-rated findings with embedded evidence, visual before/after design mockups built in CSS, a priority matrix ranked by business impact, and three-level recommendations (quick fix, proper fix, ideal state) for every issue found.

## Command

```
/eagle-ux-review
```

Also triggers on: "ux review", "ux audit", "usability review", "heuristic evaluation", "critique this design", "what's wrong with this UI"

## Required inputs

- North star metric (e.g., D7 retention, conversion rate)
- Target user profile (demographics, tech literacy, device/connectivity)
- 2-3 reference apps the target user opens daily
- App identity (chat, marketplace, tool, social, etc.)
- Screen recording (video) OR a folder of screenshots

## Optional inputs

- PRD or hypothesis document
- User personas
- Analytics data or competitive screenshots

## Output

HTML and/or Word report with:
- Central thesis
- Severity-rated findings (evidence screenshots, UX law citations, north star impact, fix recommendations)
- Priority matrix
- Visual before/after design mockups
- Time-to-first-value analysis
- UX laws summary

## Example session

```
You:   UX review this app — here's a screen recording of the onboarding flow
Claude: [asks for north star metric, target user, reference apps, app identity]
You:   North star is D7 retention. Target users are smallholder farmers in India,
       low-tech literacy, Android devices on 2G/3G. Reference apps: WhatsApp, YouTube.
       It's a chat app.
Claude: [extracts frames at 1fps, analyzes against 65+ UX laws, generates HTML report]
```

## How it works

5-phase process: context gathering, frame extraction (1fps from video), systematic analysis against 65+ UX laws (6 per-screen checks + 6 per-flow checks), HTML report generation, and quality verification.

[Read the full methodology →](../ux-review-methodology.md)
