# Eagle UX Review — Methodology

**Expert-level UX audits grounded in 65+ UX laws and principles across 12 categories.**

Most UX feedback is vague: "the onboarding feels clunky," "the colors seem off," "maybe simplify it?" This skill produces the opposite — structured, evidence-based findings where every issue is tied to a specific UX law, a specific screen, a specific element, and a specific impact on the metric you care about most.

Point Claude at a screen recording, a set of screenshots, or a PRD, and receive a complete HTML report: severity-rated findings with embedded evidence, visual before/after design mockups built in CSS, a priority matrix ranked by business impact, and three-level recommendations (quick fix, proper fix, ideal state) for every issue found.

The review is deliberately brutal. Its value comes from surfacing problems the team may not want to hear — not from validating existing decisions.

---

## What You Give the UX Review

The skill asks for structured context before analyzing anything. This context shapes every finding.

**Required inputs (the skill will ask for these):**

| Input | What it is | Why it matters |
|-------|-----------|---------------|
| **North Star Metric** | The single number that defines success for this product. Examples: conversion rate, D7 retention, tasks completed per session, revenue per user, time to first value. | Every finding in the report connects to this metric. Without it, findings are just opinions. With it, they're business cases. |
| **Target User** | Who uses this app? Demographics, tech literacy, device types, connectivity conditions, daily app habits. | A banking app for urban professionals is reviewed completely differently from a fitness tracker for casual users. The same screen can be "fine" for one audience and "broken" for another. |
| **Reference Apps** | The 2-3 apps your target user opens every day. Examples: WhatsApp, Instagram, Amazon, Spotify, YouTube. | These apps define the user's mental model. Users don't learn your app from scratch — they expect it to work like the apps they already know. Every departure from those patterns is friction. |
| **App Identity** | One-word category: chat, content, marketplace, tool, social, utility. | The skill checks whether your UI actually matches this identity. If the stated category doesn't match the UI patterns, that mismatch gets flagged as a foundational issue. |

**Extended inputs (optional, but dramatically improve the review):**

| Input | What it enables |
|-------|----------------|
| **PRD / Hypothesis Document** | Adds a full "PRD Validation" section to the report. Each product requirement is checked against what actually appears in the UI: pass, fail, or partial. |
| **User Personas** | Findings get evaluated from each persona's perspective. A feature that works for tech-savvy users may completely fail for low-literacy users. |
| **Analytics Data** | Drop-off rates, session duration, funnel completion. Lets findings reference real numbers instead of estimates. |
| **Competitive Screenshots** | Enables direct side-by-side comparisons: "Competitor X does this here; your app does that." |
| **Known Pain Points** | Focuses the review on what the team already suspects, while still covering everything else. |
| **Business Model** | Affects which engagement patterns are recommended. Ad-supported apps need session length; transaction apps need conversion. |
| **Technical Constraints** | Prevents recommending things that can't be built. |
| **Intended Happy Path** | The ideal flow: install, onboard, home, core action, repeat. Deviations from this path get flagged. |

If you provide a video and say "just review it" without answering any of these questions, the skill will infer reasonable answers from the evidence — but will call out every assumption explicitly so you can correct them.

---

## How the UX Review Works, Step by Step

### Phase 1: Context Gathering

The skill presents all required questions in a single message. No drip-feeding questions across 10 back-and-forth turns. You answer once, and the analysis begins.

If you provide a PRD, the skill extracts every testable hypothesis from it: user flow assumptions ("users will go from A to B to C"), success criteria ("80% should complete onboarding in under 60 seconds"), and feature specifications ("the search supports text, voice, and filter input"). Each one becomes a validation item in the report.

### Phase 2: Processing the Input

**For video files,** the skill extracts one frame per second using ffmpeg:

```bash
ffmpeg -i video.mp4 -vf "fps=1" -q:v 2 frames/frame_%03d.jpg
```

Why 1-second intervals instead of 2? Because screen transitions, loading spinners, and user hesitation points happen in sub-second windows. A 2-second interval misses half the story.

The skill then views **every single frame** sequentially. No sampling, no skipping. While viewing, it tracks:

- Exact frame numbers where screens change (this reconstructs timing)
- Loading and spinner durations (count frames = count seconds)
- What the user tapped (look for visual feedback, highlighted elements)
- What the user did NOT tap (elements that were available but ignored — often the most revealing signal)
- Dwell time on each screen (long pauses = confusion)

**For screenshots,** the skill views each image, confirms the flow order, and asks about missing states (loading, error, empty).

After processing, it constructs a flow map:

```
App Open → Home Screen → Feature Gate → Core Action → Result → Follow-up
 [3s load]   [5 choices]    [barrier]    [friction]   [slow render]  [dead end]
```

### Phase 3: Analysis Against 65+ UX Laws

This is the core of the review. Every screen gets evaluated against a systematic checklist:

**Per-screen (6-point check):**

| Check | What it evaluates | Key laws applied |
|-------|------------------|-----------------|
| **Identity Match** | Does this screen match what users of the reference app expect? | Jakob's Law — users spend most time on other apps and expect yours to work the same way |
| **Action Clarity** | How many choices are on this screen? Is the primary action obvious and reachable? | Hick's Law (decision paralysis) + Fitts's Law (target size and distance) |
| **Information Load** | How much must the user process or remember simultaneously? | Miller's Law (7±2 items) + Cognitive Load Theory |
| **Visual Hierarchy** | What stands out first? Is it the right thing? | Von Restorff Effect + Gestalt principles (proximity, similarity, figure-ground) |
| **Progress Signal** | Does the user feel movement toward their goal? | Goal Gradient Effect + Zeigarnik Effect (incomplete tasks stick in memory) |
| **Responsiveness** | Is feedback instant? Are waits informative? | Doherty Threshold (<400ms) + Nielsen's response time limits |

**Per-flow (6-point check):**

| Check | What it measures |
|-------|-----------------|
| **Time to First Value** | Seconds and taps from app open to first meaningful interaction. For e-commerce, this is the first product viewed. For a productivity tool, it's the first task completed. For a social app, the first content consumed. |
| **Decision Accumulation** | Total number of choices across the entire flow. Each choice adds friction (Hick's Law compounds). |
| **Emotional Curve** | Map the peak moment and the ending. People judge experiences by the best moment and the last moment, not the average (Peak-End Rule). |
| **Open Loops** | At the end of the flow, is there a reason to come back? Incomplete tasks drive return visits (Zeigarnik Effect). |
| **Identity Consistency** | Does every screen feel like the same app? Does the identity hold from onboarding through core action? |
| **Behavioral Mode** | Is the app training the user to be active (ask, create, search) or passive (scroll, browse, read)? This must match the app's goal. |

**For low-literacy audiences,** additional checks run automatically:

- Cover-the-text test: can you understand the screen without reading anything?
- Voice-only test: can the core task be completed entirely by voice?
- Reading level check: is all UI text at grade 3-5?
- Icon check: are all icons paired with labels (not icon-only)?
- Familiar-app test: does this feel like apps the target audience already uses daily?

### Phase 4: Report Generation

The skill produces a self-contained HTML file. It copies the key frames (10-15 that tell the story) into a `frames/` directory alongside the report so all images load via relative paths.

Every finding follows the same structure:

1. **Severity badge** — Critical (red), High (orange), Medium (yellow), Low (blue)
2. **Title** — what's wrong, in plain language
3. **UX law tags** — which principles are violated
4. **Evidence screenshot** — the exact frame showing the problem
5. **What happens** — observed behavior, specifically
6. **Why this matters** — how the UX law connects to the north star metric (not just "this violates Hick's Law" but "this violates Hick's Law, meaning the user faces 5 competing options at the exact moment they need to take the core action, directly suppressing conversion rate")
7. **Reference app comparison** — "Competitor X surfaces this action prominently; this app buries it three taps deep"
8. **Recommendation** — actionable fix, often with three levels: quick fix (ship this week), proper fix (next sprint), ideal state (if unconstrained)

Findings are ordered by severity multiplied by north star impact — not chronologically. The most damaging problem leads the report.

### Phase 5: Quality Checks

Before delivery, the skill verifies:
- Every finding connects to the north star metric
- Every finding has a severity rating, a UX law reference, evidence, and a recommendation
- The priority matrix is ordered by implementation priority
- Visual mockups cover at least the home screen and primary interaction
- Time-to-first-value is calculated
- All referenced frames exist and render correctly
- If a PRD was provided, every testable hypothesis is validated

---

## What the UX Report Contains

The HTML report has 9 required sections (10 if a PRD is provided):

| Section | What's in it |
|---------|-------------|
| **1. Hero / Cover** | App name, subtitle, context cards in a grid: north star metric, target user, reference apps, app identity, device/connectivity, PRD status, launch stage |
| **2. Central Thesis** | Dark box. 1-2 sentences identifying the single most fundamental problem. This is the structural issue that, if not fixed, makes all other improvements marginal. |
| **3. Executive Summary** | Four stat cards (critical/high/medium/low counts). Horizontal scroll of frame thumbnails showing the user journey with timing labels. Time-to-first-value metric. |
| **4. PRD Validation** | *(Only if PRD provided.)* Checklist of each hypothesis with pass/fail/warning icon, the hypothesis statement, observed behavior, evidence frame, and gap analysis. |
| **5. Detailed Findings** | The bulk of the report. Each finding is a left-bordered card (border color = severity) with the full evidence → analysis → recommendation structure described above. |
| **6. Priority Matrix** | Table: Priority number, issue title, recommended fix, severity, north star impact. Ordered by what to fix first. |
| **7. Visual Design Recommendations** | Side-by-side mockups in phone-shaped CSS containers. Left: current state (red border). Right: proposed state (green border). Key changes listed below each pair. Covers at minimum: home screen, primary interaction, and AI response format. |
| **8. Time to First Value** | Two timelines stacked: current flow (with red problem markers at each friction point) and target flow (streamlined). Each timeline item has a timestamp and description. |
| **9. UX Laws Violated** | Summary table: law name, specific violation, finding reference number. Quick lookup for "which findings relate to Fitts's Law?" |
| **10. Footer** | App name, review date, methodology summary, frame count, extraction interval. |

The template uses Inter font, responsive layout (works on desktop and mobile), and a severity-coded color system: critical red (`#dc2626`), high orange (`#ea580c`), medium yellow (`#ca8a04`), low blue (`#2563eb`).

---

## The 12 UX Law Categories

The review draws from 65+ laws organized into these categories. The full reference is at `eagle-ux-review/references/ux-laws.md`.

| # | Category | What it covers | Example laws |
|---|----------|---------------|-------------|
| 1 | **Heuristics & Decision Principles** | How users make choices, what makes actions easy or hard | Jakob's Law, Fitts's Law, Hick's Law, Miller's Law, Occam's Razor |
| 2 | **Gestalt Principles** | How the brain groups and interprets visual elements | Proximity, Similarity, Common Region, Figure-Ground, Closure, Continuity |
| 3 | **Cognitive Biases** | Systematic patterns in how people perceive and remember | Serial Position, Von Restorff, Peak-End Rule, Anchoring, Status Quo Bias |
| 4 | **Response Time & Feedback** | How speed and feedback affect perceived quality | Doherty Threshold, Nielsen's response limits, Skeleton Screens |
| 5 | **Complexity & Information** | How to manage inherent complexity without overwhelming users | Tesler's Law, Postel's Law, Progressive Disclosure, Cognitive Load Theory |
| 6 | **Engagement & Behavior** | What drives users to come back, invest, and form habits | Goal Gradient, Zeigarnik, Hook Model, Loss Aversion, IKEA Effect |
| 7 | **Mobile-Specific** | Touch, thumb zones, interruptions, connectivity | Thumb Zone, Touch Target Size, Offline-First, Interruption Recovery |
| 8 | **Accessibility & Inclusion** | Making products usable by everyone | WCAG Contrast, Perceivable Info, Operable Controls, Error Prevention |
| 9 | **Nielsen's 10 Heuristics** | The foundational usability checklist used by every UX professional | Visibility of Status, Match to Real World, User Control, Consistency, etc. |
| 10 | **AI-Specific Principles** | UX patterns unique to AI/ML interfaces | Expectation Setting, Streaming Response, Turn Length, Suggestion Chips, Graceful Failure |
| 11 | **Low-Literacy & Emerging Markets** | Design for users who cannot read well or are new to digital interfaces | Visual Primacy, Audio/Voice as Primary, Concrete Over Abstract, Guided Linear Flows, Meaningful Defaults, Error Tolerance, Familiar Metaphors |
| 12 | **UX Metrics & KPIs** | Quantitative benchmarks for measuring UX quality | Task Success Rate, Time on Task, SUS, NPS, CES, D1/D7/D30 Retention |
