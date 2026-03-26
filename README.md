# Eagle Skills

<!-- Badges placeholder — uncomment and update when applicable
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet)
-->

Custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool. Each skill extends Claude with domain-specific expertise, structured workflows, and production-quality deliverables.

This repo contains three skills that work together as a complete product evaluation pipeline:

1. **Eagle UX Review** — looks at your screens and tells you what's broken and why
2. **Eagle Product Diagnostics** — takes your real data and proves whether those problems actually cost you users and revenue
3. **Eagle Ad Review** — audits your ad creatives against marketing strategy, platform specs, and creative effectiveness research

Use them independently or combine them: review your product, validate with data, then audit the ads that drive users to it.

---

## Table of Contents

**Skills:**
- [Eagle UX Review](#eagle-ux-review)
- [Eagle Product Diagnostics](#eagle-product-diagnostics)
- [Eagle Ad Review](#eagle-ad-review)

**Methodology — UX Review:**
- [What You Give It](#what-you-give-the-ux-review)
- [How the Review Works, Step by Step](#how-the-ux-review-works-step-by-step)
- [What the UX Report Contains](#what-the-ux-report-contains)
- [The 12 UX Law Categories](#the-12-ux-law-categories)

**Methodology — Product Diagnostics:**
- [The Problem It Solves](#the-problem-product-diagnostics-solves)
- [The Three-Layer Model](#the-three-layer-model)
- [How Diagnostics Works, Step by Step](#how-diagnostics-works-step-by-step)
- [The Verdict Matrix](#the-verdict-matrix)
- [Input Templates](#input-templates)

**Methodology — Ad Review:**
- [Why Ad Creative Matters](#why-ad-creative-matters)
- [The 10-Dimension Scoring Framework](#the-10-dimension-scoring-framework)
- [How the Ad Review Works](#how-the-ad-review-works)
- [What the Ad Report Contains](#what-the-ad-report-contains)

**Setup:**
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [The Three-Skill Pipeline](#the-three-skill-pipeline)
- [Built With](#built-with)
- [Contributing](#contributing)
- [License](#license)

---

# Eagle UX Review

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

---

# Eagle Product Diagnostics

## The Problem Product Diagnostics Solves

A UX review tells you: "This screen probably causes drop-off because the primary action is buried."

But *probably* isn't proof. Maybe users found a workaround. Maybe the drop-off happens for a completely different reason. Maybe the screen is fine and the real problem is that the feature itself doesn't deliver enough value.

Product Diagnostics takes your actual data — analytics events from your app and outcomes from your database — and validates each UX finding against reality. The result is not "we think this is broken" but "this IS broken, here's the funnel that proves it, and here's how much it costs."

It also catches the reverse: situations where the data shows a problem that the UX review didn't predict. These are often the most important discoveries — they point to issues invisible from the interface alone (server errors, slow APIs, content quality, wrong audience targeting).

---

## The Three-Layer Model

Product Diagnostics works by triangulating three independent sources of evidence:

```
LAYER 1: DESIGN INTENT                    LAYER 2: INSTRUMENTED BEHAVIOR           LAYER 3: OUTCOME TRUTH
"We believe users will do X"              "Users actually did Y"                    "The database shows Z"
─────────────────────────────             ─────────────────────────────             ─────────────────────────────
Source: UX review findings,               Source: Firebase, Mixpanel,               Source: Database queries,
PRD, product hypotheses                   Amplitude, Segment, PostHog,             transaction logs, revenue
                                          CleverTap, Moengage, Heap,               data, retention cohorts
                                          session recordings

Answers: Is the feature well-             Answers: Did users reach it?              Answers: Did the goal
designed? Are there visible               Did they complete the flow?               actually get achieved?
friction points?                          Where did they drop off?                  Did the purchase go through?
                                                                                    Did the user come back?

Nature: Predictive.                       Nature: Observational.                    Nature: Ground truth.
Identifies potential problems.            Shows what happened but                   Shows the final result but
May not reflect real behavior.            not why, and not whether                  not the journey that led
                                          outcomes succeeded.                       to it.
```

**Why all three are necessary:**

- **Design Intent alone** is just theory. You might optimize for problems that don't actually occur.
- **Events alone** show the "what" but not the "why." You see drop-off but can't diagnose the cause.
- **DB outcomes alone** show the result but not the journey. You know revenue dropped but have no idea where to intervene.
- **Any two** still have a blind spot. Design + Events misses whether completed flows actually produced real outcomes. Design + DB can't see the journey. Events + DB has no framework for *why* things fail — fixes become guesswork.

All three together create a closed loop: **hypothesize** (design intent) → **observe** (behavior) → **verify** (outcome).

---

## How Diagnostics Works, Step by Step

### Phase 1: Gather Inputs

The skill asks for three types of data. Input templates are provided at `eagle-product-diagnostics/assets/input-templates/` — copy them, fill in your numbers, and hand them over.

**Input 1: Goal Definitions** — what "success" means for each feature, with specific target metrics.

**Input 2: Event Data** — your analytics events mapped to screens, plus funnel definitions with conversion rates. Works with any platform. Accepted formats: CSV export, JSON schema, dashboard screenshots, BigQuery query results, or even a plain-text event list with approximate numbers.

**Input 3: Database Outcomes** — actual metric values vs. targets. The most powerful variant is a **cohort comparison**: users who hit a specific UX condition vs. those who didn't.

If a UX review report from `eagle-ux-review` is also provided, the skill maps each UX finding directly to event data and DB outcomes for per-finding validation.

### Phase 2: Map Events to Flows

The skill builds an event-to-screen mapping that connects every analytics event to a specific point in the user journey:

```
Step                 Event                     Actual Rate    Expected    Gap
────────────────────────────────────────────────────────────────────────────────
1. App Open          app_open                  100%           100%        —
2. Home Screen       screen_view:home          92%            >95%        -3%
3. Category Select   screen_view:category      68%            >85%        -17% !
4. Feature Entry     feature_started           28%            >60%        -32% !!
5. Core Action       action_completed          18%            >48%        -30% !!
6. Result Screen     result_displayed          16%            >45%        -29%
```

For each step, it calculates:
- **Absolute conversion** from baseline (what percentage of all users reach this point)
- **Step-to-step conversion** (what percentage of the previous step proceeds)
- **Drop-off magnitude** (how many users are lost here)
- **Time between events** (if timestamps are available — long gaps signal confusion or technical issues)
- **Comparison to expected rates** (from your goal definitions)

The biggest drops get flagged. In the example above, the 68% → 28% drop between category selection and feature entry is where most users are lost — the intermediate step loses 40% of traffic.

### Phase 3: Triangulate

For each feature/goal, the skill produces a three-layer verdict:

```
FEATURE: Complete a purchase
GOAL: User adds item to cart AND completes checkout

┌─────────────────────────────────────────────────────────────────────────┐
│ Layer 1 — DESIGN INTENT                                         FAIL  │
│ UX review found: primary CTA below the fold, 6-step checkout          │
│ with no progress indicator, mandatory account creation blocks          │
│ 40% of users before payment.                                          │
├─────────────────────────────────────────────────────────────────────────┤
│ Layer 2 — INSTRUMENTED BEHAVIOR                                 FAIL  │
│ Analytics events confirm: only 28% of product viewers add to          │
│ cart. 60% drop-off at account creation step. Users who reach          │
│ the payment screen have 0.3 completion rate.                          │
├─────────────────────────────────────────────────────────────────────────┤
│ Layer 3 — OUTCOME TRUTH                                         FAIL  │
│ Database shows: conversion rate = 1.2% (target: 4%). Average          │
│ order value is healthy at $47, but volume is suppressed.              │
│ 68% of cart creators never complete payment.                          │
├─────────────────────────────────────────────────────────────────────────┤
│ DIAGNOSIS: All three layers agree. This is a clear UX problem.        │
│ The checkout flow suppresses the core conversion action.              │
│                                                                        │
│ VALIDATED IMPACT: ~2,400 missed conversions/month, ~$112K in          │
│ unrealized revenue. Removing mandatory signup could recover 40%.      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Phase 4: Generate Report

The output is an HTML report (matching the brutalist style of the UX review) containing:

| Section | What's in it |
|---------|-------------|
| **1. Cover** | Product name, data sources used, date range, sample sizes |
| **2. Input Summary** | What data was provided, what's missing, overall confidence level |
| **3. Goal Scorecard** | Table with every feature, its goal, and three PASS/FAIL/PARTIAL verdicts |
| **4. Funnel Analysis** | Visual funnel bars showing conversion and drop-off at each step |
| **5. Finding Validation** | Each UX review finding mapped to events and DB outcomes |
| **6. Diagnosis by Feature** | Deep dive for each feature with all three layers, interpretation, and action |
| **7. Disagreement Analysis** | Where layers contradict — and what that means |
| **8. Metric Impact** | Business impact estimates with calculations showing revenue/retention/cost |
| **9. Recommended Actions** | Prioritized by validated impact (not just UX severity) |
| **10. Data Gaps** | Missing events, missing instrumentation, what to add for better diagnosis next time |

### Phase 5: Writing Principles

- **Let the data speak.** If the numbers tell a different story than the UX review predicted, the data wins.
- **Flag uncertainty.** Small sample sizes, missing events, and single-source verdicts get called out explicitly.
- **Distinguish correlation from causation.** "Users who skip step 3 have 3x retention" is strong evidence, not proof.
- **Quantify everything.** "Drop-off is high" is weak. "47% of users abandon at step 3, costing an estimated 2,400 conversions/month" is actionable.
- **Challenge the hypothesis.** If data says UX is fine but the metric is failing, say so. The problem might be content quality, market fit, or technical reliability.

---

## The Verdict Matrix

The power of three-layer validation is in the combinations. Here's what each pattern means:

| UX | Events | DB | What it means | Real-world example | What to do |
|----|--------|----|--------------|--------------------|-----------|
| FAIL | FAIL | FAIL | **Clear UX problem.** The interface is broken, users are struggling, and the metric is suffering. All evidence agrees. | Checkout button hidden below fold → users can't complete purchase → conversion rate is 12% instead of target 40% | Fix the UX. Highest confidence, highest priority. |
| FAIL | PASS | PASS | **Users adapted.** The UX looks bad but users found a workaround and the metric is fine. | Confusing settings menu, but users learned the path after 2 sessions and retention is healthy | Monitor but lower priority. Consider fixing for new user onboarding. |
| PASS | FAIL | FAIL | **Hidden problem.** The UX looks fine in review but something else is causing failure — slow APIs, bad content, wrong audience segment, device-specific bugs. | Clean checkout flow, but 30% of payments silently fail on Android due to a payment SDK bug | Investigate technical and content layers. The UX isn't the bottleneck. |
| PASS | PASS | FAIL | **Value proposition problem.** Users find and use the feature successfully, but the business goal still isn't met. This is a strategy issue, not a design issue. | Users complete onboarding smoothly, ask questions daily, but D30 retention is 3% because the AI answers aren't useful enough | Don't blame UX. Investigate content quality, product-market fit, or whether the goal target is realistic. |
| FAIL | FAIL | PASS | **Power users compensating.** The UX has friction and most users struggle, but the ones who push through are highly engaged. You're leaving the mass market on the table. | Power users navigate a complex interface and love the tool, but 80% of new users never get past onboarding | Fix the UX to unlock the mass market. Current users succeed despite the interface, not because of it. |
| PASS | FAIL | PASS | **Measurement problem.** UX is fine, outcomes are fine, but events show drop-off. Likely a tracking issue — missing events, misconfigured funnels, or users taking an untracked path. | Funnel shows 50% drop at step 3, but DB shows 90% of users complete the action. Users are using a different path than the one instrumented. | Fix the instrumentation before drawing conclusions. |
| FAIL | PASS | FAIL | **Delayed damage.** UX problems don't cause immediate drop-off (users push through) but erode long-term retention or satisfaction. | Users complete their first session despite confusing navigation, but don't come back on Day 7. | Fix UX for retention. Short-term funnels look fine but the experience doesn't earn a return visit. |
| PASS | PASS | PASS | **Working as intended.** Feature is well-designed, well-used, and achieving its goals. | Onboarding is clean, completion rate is 85%, D7 retention for onboarded users is 35%. | Protect this. Don't redesign what works. Document the patterns for reuse. |

---

## Input Templates

To run Product Diagnostics, provide three inputs. Templates are included in the skill at `eagle-product-diagnostics/assets/input-templates/`:

### 1. Goal Definition (`goal-definition.md`)

Define what "success" means for each feature you want to validate:

```
Feature: Complete first purchase
User Story: As a new user, I want to find and buy a product so I get value from the app.
Success: User adds item to cart AND completes checkout AND returns within 7 days.

Metric              Current    Target     Window
─────────────────────────────────────────────────
Conversion rate     12%        40%        per session
D7 retention        8%         20%        cohort
Task completion     35%        70%        per attempt

Happy Path:
  1. User opens app
  2. User browses or searches for product
  3. User selects product and adds to cart
  4. User completes checkout
  5. User receives confirmation and returns

Known Risks:
  - Assumes user discovers products organically
  - Payment options may not cover all regions
  - Depends on network connectivity
```

### 2. Event Taxonomy (`event-taxonomy.md`)

Map your analytics events to screens and define the funnels you care about:

```
Event Name              Trigger                    Screen
──────────────────────────────────────────────────────────
app_open                App launched               --
screen_view:home        Home screen displayed       Home
product_viewed          User views product detail   Product
add_to_cart             User adds item to cart      Product
checkout_completed      Purchase confirmed          Checkout

Funnel: First Purchase
  app_open → screen_view:home → product_viewed → add_to_cart → checkout_completed
  Expected: 100% → 95% → 60% → 80% → 95%
  Actual:   100% → 92% → 28% → 65% → 89%
```

Works with any analytics platform: Firebase, Mixpanel, Amplitude, Segment, CleverTap, Moengage, PostHog, Heap, or custom. Provide data as CSV, JSON, BigQuery exports, dashboard screenshots, or even plain-text approximations.

### 3. Database Outcomes (`db-schema.md`)

Provide ground truth — what actually happened vs. what should have happened:

```sql
SELECT
  COUNT(DISTINCT user_id) as users,
  AVG(purchases_per_session) as avg_purchases,
  AVG(CASE WHEN returned_day_7 THEN 1 ELSE 0 END) as d7_retention
FROM user_metrics
WHERE signup_date BETWEEN '2026-01-01' AND '2026-03-25';

-- Result: 8,200 users, 0.3 avg purchases, 8% D7 retention
-- Target: 1+ purchases per session, 20% D7 retention
```

**Cohort comparisons are the most powerful input.** If you can split users into groups based on a UX condition, the diagnosis becomes conclusive:

```
                    Complex checkout    Streamlined checkout    Difference
─────────────────────────────────────────────────────────────────────────
Conversion rate     12%                 41%                     +242%
D7 retention        4%                  22%                     +18pp
Session duration    45s                 4m 20s                  +478%
```

This proves a UX bottleneck isn't just a design problem — it's a retention problem with a measurable cost.

---

# Eagle Ad Review

**Strategy-first advertising creative review grounded in Meta ABCD, Kantar, System1, and Nielsen frameworks. Works across any medium.**

Most ad feedback is subjective: "I don't like the colors," "make the logo bigger," "this doesn't feel right." This skill produces the opposite — a structured evaluation where every creative is scored against the marketing strategy it's supposed to serve, the medium it runs in, and the research on what actually drives ad performance.

Point Claude at a folder of ad files — images, videos, audio, PDFs, scripts — across **any advertising medium**: social, display, video, radio, podcast, billboard, transit, print, TV, or experiential. Provide your campaign context and receive a complete HTML report: 10-dimension scoring, per-market breakdowns, best/worst performer galleries, cross-cutting findings with evidence, format compliance audit, and a creative brief for the next production round.

The review evaluates creatives against their **marketing job**, not just visual aesthetics. An ugly ad that stops the scroll and converts is better than a beautiful ad nobody notices. A simple billboard that communicates in 3 seconds beats an elaborate one nobody can read at 60mph.

---

## Why Ad Creative Matters

Creative quality is the single largest driver of advertising effectiveness:

| Research Source | Finding |
|----------------|---------|
| **Nielsen** | Creative quality accounts for **47% of sales lift** from advertising |
| **Google/Meta** | **56% of digital ad ROI** is attributable to creative |
| **IPA Databank** (1,400+ cases) | Emotionally-led campaigns outperform rational ones **2x on profit** |
| **System1** | 5-star "famous" ads are **10x more efficient** at driving market share than 1-star ads |
| **Meta** | **85% of feed video** is watched on mute — captions are essential |

Yet most teams spend 90% of their ad budget on media buying and 10% on creative. This skill exists to make creative quality measurable, not subjective.

---

## The 10-Dimension Scoring Framework

Every creative is scored across 10 dimensions. Weighted total produces an overall score out of 100.

| # | Dimension | Weight | What It Measures |
|---|-----------|--------|-----------------|
| 1 | **Attention / Hook** | 15% | Does it stop the scroll in 1-3 seconds? Pattern interrupt, bold visual, or provocative statement? |
| 2 | **Message Clarity** | 15% | Is the value proposition instantly understandable? One idea, clearly stated? |
| 3 | **Brand Presence** | 12% | Is the brand identifiable within 3 seconds? Logo, colors, distinctive assets? |
| 4 | **CTA Effectiveness** | 12% | Is there a clear, prominent, funnel-appropriate call-to-action? |
| 5 | **Platform Compliance** | 10% | Correct aspect ratio, safe zones respected, text limits met, format matches placement? |
| 6 | **Visual Quality** | 10% | Professional production? Composition, contrast, typography, authentic imagery? |
| 7 | **Emotional Resonance** | 8% | Does it connect emotionally? Human faces, storytelling, relatability? |
| 8 | **Cultural Fit & Localization** | 7% | Transcreated (not just translated)? Culturally appropriate? No mixed languages? |
| 9 | **Accessibility & Readability** | 6% | Readable on mobile? Captions on video? Sufficient contrast? |
| 10 | **Creative System & Testing** | 5% | Is the set structured for testing? Hook/body/CTA variations? Or random batches? |

**Weights adjust by campaign type:**
- **Awareness campaigns:** Emotion ↑ to 12%, CTA ↓ to 8%
- **Direct response:** CTA ↑ to 15%, Message ↑ to 18%, Emotion ↓ to 5%
- **Multi-market:** Cultural Fit ↑ to 12%
- **Brand campaigns:** Brand Presence ↑ to 15%, Emotion ↑ to 12%

**Rating scale:**

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Exceptional | World-class creative |
| 75-89 | Strong | Competitive, minor improvements |
| 60-74 | Average | Functional but significant opportunity |
| 45-59 | Below Average | Multiple issues suppressing performance |
| 30-44 | Weak | Fundamental problems, overhaul needed |
| <30 | Critical | Actively wasting spend |

---

## How the Ad Review Works

### Step 1: Understand the Marketing Strategy

Before evaluating a single creative, the skill collects campaign context. This is what separates a strategic review from aesthetic criticism.

**Campaign Strategy:**
- **Campaign Objective** — Awareness, installs, conversions, retargeting, re-engagement, lead gen
- **Funnel Stage** — Cold (first exposure), warm (consideration), hot (retargeting)
- **Target Audience** — Per market: demographics, psychographics, media habits, pain points
- **Platforms & Placements** — Where these run: Meta Feed, Stories, Reels, TikTok, YouTube, Display, LinkedIn, Pinterest
- **Primary KPI** — CTR, CPA, ROAS, install rate, video completion rate, brand lift

**Brand & Product:**
- **Value Proposition** — The single most compelling reason to care
- **Brand Positioning** — How the brand should be perceived
- **Competitive Landscape** — Who's fighting for the same eyeballs

**Extended (if available):**
- Performance data (CTR, CPA by creative)
- Brand guidelines (logo rules, colors, typography)
- Creative testing history (what's worked, what hasn't)
- Budget context (affects recommendation feasibility)

### Step 2: Catalog and Process Creatives

The skill scans the entire ad folder, catalogs every file by type/dimensions/aspect ratio, groups by market and concept, and generates thumbnails for the report.

- Images: viewed and grouped by market, format, concept
- Videos: key frames extracted (hook frame, middle, CTA frame), duration/resolution logged
- Organization: files mapped to a creative inventory (Market → Format → Concept → Variations)

### Step 3: Three-Level Analysis

**Level 1 — Strategic Fit** (most important): Does each creative do the job the campaign needs? Right hook for the funnel stage? Value proposition clear in 3 seconds? CTA matches objective?

**Level 2 — Execution Quality**: Is it well-made? Brand presence, visual hierarchy, platform compliance, production quality, localization quality?

**Level 3 — Creative System Health**: Does the creative set work as a testing/optimization system? Structured hook/body/CTA variations? Meaningful concept diversity? Fatigue management?

### Step 4: Score and Report

Every creative gets a 10-dimension score card. Cross-cutting findings are identified across the set. Everything compiles into the HTML report.

---

## What the Ad Report Contains

| Section | What's In It |
|---------|-------------|
| **1. Cover** | Campaign context cards: objective, audience, platforms, KPI, markets, creative count |
| **2. Overall Verdict** | Score out of 100 with 1-2 sentence thesis |
| **3. Creative Inventory** | File counts by market, format, concept, medium |
| **4. Scoring Dashboard** | 10-dimension scores with visual bars and weighted overall |
| **5. Best & Worst Performers** | Gallery with thumbnails — top 3 and bottom 3 with explanations |
| **6. Market Breakdown** | Score and key findings per market or campaign group |
| **7. Cross-Cutting Findings** | Issues across the set, ordered by KPI impact, with evidence thumbnails and recommendations |
| **8. Platform Compliance** | Pass/fail table per creative against platform specs |
| **9. Creative System Assessment** | Testing framework evaluation, variation analysis, fatigue risk |
| **10. Recommended Actions** | Three levels: quick fix (this week), next sprint, strategic shift |
| **11. Creative Brief** | What to make next, based on findings |

---

## Installation

Install any or all skills. Symlink is recommended for automatic updates.

### Option A: Symlink (recommended)

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
ln -sf "$(pwd)/eagle-product-diagnostics" ~/.claude/skills/eagle-product-diagnostics
ln -sf "$(pwd)/eagle-ad-review" ~/.claude/skills/eagle-ad-review
```

Updates automatically when you `git pull`. Breaks if you move the cloned repo.

### Option B: Copy

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cp -r eagle-skills/eagle-ux-review ~/.claude/skills/
cp -r eagle-skills/eagle-product-diagnostics ~/.claude/skills/
cp -r eagle-skills/eagle-ad-review ~/.claude/skills/
```

Standalone. Requires manual re-copy to get updates.

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- `ffmpeg` and `ffprobe` — required for video input in UX Review and Ad Review
  ```bash
  # macOS
  brew install ffmpeg

  # Ubuntu/Debian
  sudo apt install ffmpeg
  ```
- `imagemagick` — optional, used by Ad Review's catalog script for thumbnail generation and image dimension detection
  ```bash
  # macOS
  brew install imagemagick

  # Ubuntu/Debian
  sudo apt install imagemagick
  ```

---

## Usage

Trigger skills with natural language in Claude Code:

**UX Review:**
```
ux review this screen recording
```
```
critique this design — here are the screenshots
```
```
run a heuristic evaluation of our onboarding flow
```
```
UX audit — I'll provide a PRD and video walkthrough
```

**Product Diagnostics:**
```
validate these UX findings against our Firebase events
```
```
why isn't our retention metric moving? here's the event data and DB export
```
```
triangulate UX and analytics — I'll provide the goal definitions and funnel data
```
```
is this feature actually working? here's what the database shows
```

**Ad Review:**
```
review these ad creatives — here's the folder
```
```
audit our campaign creatives for Meta and TikTok
```
```
critique our radio spots and billboard designs
```
```
ad creative review — I'll provide the campaign context and performance data
```
```
review our TV commercial and print ads for the new campaign
```

Skills activate automatically when Claude detects matching intent.

---

## The Three-Skill Pipeline

Each skill is powerful alone. Together, they cover the full product lifecycle: the experience inside the product, the data proving what works, and the ads driving users to it.

```
Step 1: UX Review              Step 2: Product Diagnostics       Step 3: Ad Review
──────────────────             ─────────────────────────────     ─────────────────────
Input:  Screen recording       Input:  UX report + events + DB   Input:  Ad folder + strategy
Output: "Here's what's         Output: "Here's proof it IS       Output: "Here's what's wrong
         broken in the UX"              broken, and the cost"             with your ads"

Predictive                     Validated                          Acquisition
"This will hurt retention"     "This DID hurt retention by 14pp"  "Ads aren't doing their job"
```

**Why all three matter:**
- UX Review alone gives you well-reasoned predictions without proof.
- Product Diagnostics alone gives you data without actionable design recommendations.
- Ad Review alone tells you what's wrong with creatives without knowing if the product delivers.
- Together, you validate the entire user journey: ads bring users in → the product retains them → the data proves it works.

---

## Built With

- **[Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's skill system for extending Claude with domain expertise
- **ffmpeg** — video frame extraction at configurable intervals
- **65+ UX laws** curated from established HCI research: Medhi et al. (2011), Nielsen (1994), Gestalt psychology, Fitts (1954), GSMA Mobile for Development, and more
- **Three-layer triangulation framework** combining UX analysis, behavioral analytics, and outcome data
- **Ad creative effectiveness research** from Meta ABCD, Kantar (200K+ ad database), System1, Nielsen, IPA Databank (1,400+ case studies)
- **Platform-specific ad specs** for Meta, Google, TikTok, LinkedIn, X, and Pinterest

---

## Contributing

Contributions are welcome. Areas where help is especially valuable:

- **New UX law categories** — additional principles with audit checklists
- **Analytics platform integrations** — better export guides for niche platforms
- **Report template improvements** — accessibility, print styles, dark mode
- **New skills** — other review types (accessibility audit, content strategy review, competitor teardown) following the same pattern
- **Ad platform updates** — specs change frequently; keep ad-platforms.md current
- **Language/localization** — report templates and UX law references in other languages
- **Real-world case studies** — anonymized examples showing the two-skill workflow in action

To contribute:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test by installing the skill locally and running a review
5. Submit a pull request with a clear description of what changed and why

---

## License

MIT
