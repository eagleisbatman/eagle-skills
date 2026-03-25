# Eagle Skills

<!-- Badges placeholder — uncomment and update when applicable
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet)
-->

Custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool. Each skill extends Claude with domain-specific expertise, structured workflows, and production-quality deliverables.

This repo contains two skills that work together as a complete product evaluation pipeline:

1. **Eagle UX Review** — looks at your screens and tells you what's broken and why
2. **Eagle Product Diagnostics** — takes your real data and proves whether those problems actually cost you users and revenue

Use them independently or as a two-step workflow: review first, validate second.

---

## Table of Contents

**Skills:**
- [Eagle UX Review](#eagle-ux-review)
- [Eagle Product Diagnostics](#eagle-product-diagnostics)

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

**Setup:**
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [The Two-Skill Workflow](#the-two-skill-workflow)
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
| **North Star Metric** | The single number that defines success for this product. Examples: queries per user, conversion rate, D7 retention, revenue per user. | Every finding in the report connects to this metric. Without it, findings are just opinions. With it, they're business cases. |
| **Target User** | Who uses this app? Demographics, tech literacy, device types, connectivity conditions, daily app habits. | A banking app for urban professionals is reviewed completely differently from a farming assistant for rural users on 2G. The same screen can be "fine" for one audience and "broken" for another. |
| **Reference Apps** | The 2-3 apps your target user opens every day. For rural East Africa, that's WhatsApp. For US teens, that's TikTok and Instagram. | These apps define the user's mental model. Users don't learn your app from scratch — they expect it to work like the apps they already know. Every departure from those patterns is friction. |
| **App Identity** | One-word category: chat, content, marketplace, tool, social, utility. | The skill checks whether your UI actually matches this identity. If you say "chat" but your home screen is a content feed, that's the foundational problem — and it gets flagged before anything else. |

**Extended inputs (optional, but dramatically improve the review):**

| Input | What it enables |
|-------|----------------|
| **PRD / Hypothesis Document** | Adds a full "PRD Validation" section to the report. Each product requirement is checked against what actually appears in the UI: pass, fail, or partial. |
| **User Personas** | Findings get evaluated from each persona's perspective. A feature that works for tech-savvy users may completely fail for low-literacy users. |
| **Analytics Data** | Drop-off rates, session duration, funnel completion. Lets findings reference real numbers instead of estimates. |
| **Competitive Screenshots** | Enables direct side-by-side comparisons: "WhatsApp does X here; your app does Y." |
| **Known Pain Points** | Focuses the review on what the team already suspects, while still covering everything else. |
| **Business Model** | Affects which engagement patterns are recommended. Ad-supported apps need session length; transaction apps need conversion. |
| **Technical Constraints** | Prevents recommending things that can't be built. |
| **Intended Happy Path** | The ideal flow: install, onboard, home, core action, repeat. Deviations from this path get flagged. |

If you provide a video and say "just review it" without answering any of these questions, the skill will infer reasonable answers from the evidence — but will call out every assumption explicitly so you can correct them.

---

## How the UX Review Works, Step by Step

### Phase 1: Context Gathering

The skill presents all required questions in a single message. No drip-feeding questions across 10 back-and-forth turns. You answer once, and the analysis begins.

If you provide a PRD, the skill extracts every testable hypothesis from it: user flow assumptions ("users will go from A to B to C"), success criteria ("80% should complete onboarding in under 60 seconds"), and feature specifications ("the chat supports text, voice, and image input"). Each one becomes a validation item in the report.

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
App Open → Home Screen → Mode Select → Chat → AI Response → Follow-up
 [3s load]   [5 choices]   [gate]      [no input]  [wall of text]  [dead end]
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
| **Time to First Value** | Seconds and taps from app open to first meaningful interaction. For a chat app, this is the first AI response. For e-commerce, the first product viewed. |
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
- Familiar-app test: does this feel like WhatsApp or YouTube?

### Phase 4: Report Generation

The skill produces a self-contained HTML file. It copies the key frames (10-15 that tell the story) into a `frames/` directory alongside the report so all images load via relative paths.

Every finding follows the same structure:

1. **Severity badge** — Critical (red), High (orange), Medium (yellow), Low (blue)
2. **Title** — what's wrong, in plain language
3. **UX law tags** — which principles are violated
4. **Evidence screenshot** — the exact frame showing the problem
5. **What happens** — observed behavior, specifically
6. **Why this matters** — how the UX law connects to the north star metric (not just "this violates Hick's Law" but "this violates Hick's Law, meaning the user faces 5 competing options at the exact moment they need to ask their first question, directly suppressing queries per user")
7. **Reference app comparison** — "WhatsApp shows a text input at the bottom; this app has no visible input field"
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
| **2. Central Thesis** | Dark box. 1-2 sentences identifying the single most fundamental problem. Example: "FarmerChat is a content app pretending to be a chat app — the UI trains passive browsing when the north star requires active querying." |
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

A UX review tells you: "This screen probably causes drop-off because the input field is missing."

But *probably* isn't proof. Maybe users found a workaround. Maybe the drop-off happens for a completely different reason. Maybe the screen is fine and the real problem is that the AI responses aren't useful.

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
3. Mode Selection    screen_view:mode_select   68%            (skip)      GATE
4. Chat Started      chat_started              28%            >60%        -32% !!
5. First Query       user_message_sent         18%            >48%        -30% !!
6. AI Response       ai_response_displayed     16%            >45%        -29%
```

For each step, it calculates:
- **Absolute conversion** from baseline (what percentage of all users reach this point)
- **Step-to-step conversion** (what percentage of the previous step proceeds)
- **Drop-off magnitude** (how many users are lost here)
- **Time between events** (if timestamps are available — long gaps signal confusion or technical issues)
- **Comparison to expected rates** (from your goal definitions)

The biggest drops get flagged. In the example above, the 68% → 28% drop between mode selection and chat is where most users are lost — 40% of users who see the mode gate never start a chat.

### Phase 3: Triangulate

For each feature/goal, the skill produces a three-layer verdict:

```
FEATURE: Ask a farming question
GOAL: User sends a query AND returns within 7 days

┌─────────────────────────────────────────────────────────────────────────┐
│ Layer 1 — DESIGN INTENT                                         FAIL  │
│ UX review found: no visible text input on home screen, mode           │
│ selection gate blocks 40% of users, AI responses are 300+ word        │
│ walls of text with no follow-up suggestions.                          │
├─────────────────────────────────────────────────────────────────────────┤
│ Layer 2 — INSTRUMENTED BEHAVIOR                                 FAIL  │
│ Firebase events confirm: only 28% of users who see the home           │
│ screen ever start a chat. 60% drop-off at mode selection gate.        │
│ Users who reach the AI response screen have 0.3 follow-up rate.       │
├─────────────────────────────────────────────────────────────────────────┤
│ Layer 3 — OUTCOME TRUTH                                         FAIL  │
│ Database shows: median queries/session = 1.1 (target: 3+).           │
│ D7 retention = 8% (target: 20%). 68% of users never send a           │
│ single query.                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ DIAGNOSIS: All three layers agree. This is a clear UX problem.        │
│ The interface suppresses the core action.                              │
│                                                                        │
│ VALIDATED IMPACT: ~2,400 missed queries/month, ~$X in unrealized      │
│ engagement. Fixing the mode gate alone could recover 40% of users.    │
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
- **Distinguish correlation from causation.** "Users who skip the mode gate have 3x retention" is strong evidence, not proof.
- **Quantify everything.** "Drop-off is high" is weak. "47% of users abandon at mode selection, costing an estimated 2,400 queries/month" is actionable.
- **Challenge the hypothesis.** If data says UX is fine but the metric is failing, say so. The problem might be content quality, market fit, or technical reliability.

---

## The Verdict Matrix

The power of three-layer validation is in the combinations. Here's what each pattern means:

| UX | Events | DB | What it means | Real-world example | What to do |
|----|--------|----|--------------|--------------------|-----------|
| FAIL | FAIL | FAIL | **Clear UX problem.** The interface is broken, users are struggling, and the metric is suffering. All evidence agrees. | No text input field → users can't start a chat → queries/session is 1.1 instead of 3+ | Fix the UX. Highest confidence, highest priority. |
| FAIL | PASS | PASS | **Users adapted.** The UX looks bad but users found a workaround and the metric is fine. | Confusing settings menu, but users learned the path after 2 sessions and retention is healthy | Monitor but lower priority. Consider fixing for new user onboarding. |
| PASS | FAIL | FAIL | **Hidden problem.** The UX looks fine in review but something else is causing failure — slow APIs, bad content, wrong audience segment, device-specific bugs. | Clean checkout flow, but 30% of payments silently fail on Android due to a payment SDK bug | Investigate technical and content layers. The UX isn't the bottleneck. |
| PASS | PASS | FAIL | **Value proposition problem.** Users find and use the feature successfully, but the business goal still isn't met. This is a strategy issue, not a design issue. | Users complete onboarding smoothly, ask questions daily, but D30 retention is 3% because the AI answers aren't useful enough | Don't blame UX. Investigate content quality, product-market fit, or whether the goal target is realistic. |
| FAIL | FAIL | PASS | **Power users compensating.** The UX has friction and most users struggle, but the ones who push through are highly engaged. You're leaving the mass market on the table. | Expert farmers navigate a complex interface and love the app, but 80% of new users never get past onboarding | Fix the UX to unlock the mass market. Current users succeed despite the interface, not because of it. |
| PASS | FAIL | PASS | **Measurement problem.** UX is fine, outcomes are fine, but events show drop-off. Likely a tracking issue — missing events, misconfigured funnels, or users taking an untracked path. | Funnel shows 50% drop at step 3, but DB shows 90% of users complete the action. Users are using a different path than the one instrumented. | Fix the instrumentation before drawing conclusions. |
| FAIL | PASS | FAIL | **Delayed damage.** UX problems don't cause immediate drop-off (users push through) but erode long-term retention or satisfaction. | Users complete their first session despite confusing navigation, but don't come back on Day 7. | Fix UX for retention. Short-term funnels look fine but the experience doesn't earn a return visit. |
| PASS | PASS | PASS | **Working as intended.** Feature is well-designed, well-used, and achieving its goals. | Onboarding is clean, completion rate is 85%, D7 retention for onboarded users is 35%. | Protect this. Don't redesign what works. Document the patterns for reuse. |

---

## Input Templates

To run Product Diagnostics, provide three inputs. Templates are included in the skill at `eagle-product-diagnostics/assets/input-templates/`:

### 1. Goal Definition (`goal-definition.md`)

Define what "success" means for each feature you want to validate:

```
Feature: Ask a farming question
User Story: As a farmer, I want to ask about my sick crop so I get treatment advice.
Success: User sends a query AND gets a useful response AND returns within 7 days.

Metric              Current    Target     Window
─────────────────────────────────────────────────
Queries/session     1.1        3+         per session
D7 retention        8%         20%        cohort
Task completion     35%        70%        per attempt

Happy Path:
  1. User opens app
  2. User taps chat input
  3. User types or speaks question
  4. AI responds with advice
  5. User asks follow-up

Known Risks:
  - Assumes user knows what to ask
  - Voice input may not work for all dialects
  - Depends on network connectivity
```

### 2. Event Taxonomy (`event-taxonomy.md`)

Map your analytics events to screens and define the funnels you care about:

```
Event Name              Trigger                    Screen
──────────────────────────────────────────────────────────
app_open                App launched               --
screen_view:home        Home screen displayed       Home
chat_started            User enters chat            Chat
user_message_sent       User sends message          Chat
ai_response_displayed   AI response shown           Chat

Funnel: First Query
  app_open → screen_view:home → chat_started → user_message_sent → ai_response_displayed
  Expected: 100% → 95% → 60% → 80% → 95%
  Actual:   100% → 92% → 28% → 65% → 89%
```

Works with any analytics platform: Firebase, Mixpanel, Amplitude, Segment, CleverTap, Moengage, PostHog, Heap, or custom. Provide data as CSV, JSON, BigQuery exports, dashboard screenshots, or even plain-text approximations.

### 3. Database Outcomes (`db-schema.md`)

Provide ground truth — what actually happened vs. what should have happened:

```sql
SELECT
  COUNT(DISTINCT user_id) as users,
  AVG(queries_per_session) as avg_queries,
  AVG(CASE WHEN returned_day_7 THEN 1 ELSE 0 END) as d7_retention
FROM user_metrics
WHERE signup_date BETWEEN '2026-01-01' AND '2026-03-25';

-- Result: 8,200 users, 1.1 avg queries, 8% D7 retention
-- Target: 3+ queries, 20% D7 retention
```

**Cohort comparisons are the most powerful input.** If you can split users into groups based on a UX condition, the diagnosis becomes conclusive:

```
                    Hit mode gate    Direct to chat    Difference
────────────────────────────────────────────────────────────────
Queries/session     0.8              3.4               +325%
D7 retention        4%               22%               +18pp
Session duration    45s              4m 20s            +478%
```

This proves the mode gate isn't just a UX problem — it's a retention problem with a measurable cost.

---

## Installation

Install one or both skills. Symlink is recommended for automatic updates.

### Option A: Symlink (recommended)

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
ln -sf "$(pwd)/eagle-product-diagnostics" ~/.claude/skills/eagle-product-diagnostics
```

Updates automatically when you `git pull`. Breaks if you move the cloned repo.

### Option B: Copy

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cp -r eagle-skills/eagle-ux-review ~/.claude/skills/
cp -r eagle-skills/eagle-product-diagnostics ~/.claude/skills/
```

Standalone. Requires manual re-copy to get updates.

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- `ffmpeg` and `ffprobe` — required for video input in UX Review
  ```bash
  # macOS
  brew install ffmpeg

  # Ubuntu/Debian
  sudo apt install ffmpeg
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

Skills activate automatically when Claude detects matching intent.

---

## The Two-Skill Workflow

The most powerful way to use these skills is sequentially:

```
Step 1: UX Review                          Step 2: Product Diagnostics
──────────────────                         ─────────────────────────────
Input:  Screen recording or screenshots     Input:  UX report + event data + DB outcomes
Output: "Here's what looks broken           Output: "Here's proof it IS broken,
         and why, grounded in UX law"                and here's how much it costs"

Predictive                                  Validated
"This will probably hurt retention"         "This DID hurt retention by 14pp"
```

**Why both matter:**
- UX Review alone gives you well-reasoned predictions without proof.
- Product Diagnostics alone gives you data without actionable design recommendations.
- Together, you get validated findings with both the diagnosis (UX) and the evidence (data), making the case for fixing things undeniable.

---

## Built With

- **[Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's skill system for extending Claude with domain expertise
- **ffmpeg** — video frame extraction at configurable intervals
- **65+ UX laws** curated from established HCI research: Medhi et al. (2011), Nielsen (1994), Gestalt psychology, Fitts (1954), GSMA Mobile for Development, and more
- **Three-layer triangulation framework** combining UX analysis, behavioral analytics, and outcome data

---

## Contributing

Contributions are welcome. Areas where help is especially valuable:

- **New UX law categories** — additional principles with audit checklists
- **Analytics platform integrations** — better export guides for niche platforms
- **Report template improvements** — accessibility, print styles, dark mode
- **New skills** — other review types (accessibility audit, performance review, API design review) following the same pattern
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
