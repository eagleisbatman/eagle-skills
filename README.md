# Eagle Skills

<!-- Badges placeholder — uncomment and update when applicable
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet)
-->

Custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool. Each skill extends Claude with domain-specific expertise, structured workflows, and production-quality deliverables.

---

## Table of Contents

**Skills:**
- [Eagle UX Review](#eagle-ux-review)
- [Eagle Product Diagnostics](#eagle-product-diagnostics) (NEW)

**UX Review:**
- [How It Works](#how-it-works)
- [Report Preview](#report-preview)

**Product Diagnostics:**
- [The Three-Layer Model](#the-three-layer-model)
- [Input Templates](#input-templates)

**Setup:**
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Built With](#built-with)
- [Contributing](#contributing)
- [License](#license)

---

## Eagle UX Review

**Expert-level UX audits grounded in 65+ UX laws and principles across 12 categories.**

Point Claude at a screen recording, screenshot set, or PRD, and receive a structured HTML report with severity-rated findings, embedded evidence, visual design mockups, and actionable recommendations tied to your north star metric.

Designed for product teams, solo founders, and design reviewers who need honest, specific, evidence-backed UX feedback — not vague platitudes.

**Key capabilities:**

- **65+ UX laws** organized across 12 categories, including dedicated Low-Literacy and Emerging Market Design principles
- **Video analysis** with 1-second frame extraction to capture transitions, loading states, and hesitation signals
- **PRD validation** — checks whether implementation matches product hypotheses
- **Structured context gathering** — north star metrics, personas, analytics, competitive benchmarks
- **RICE + UX severity prioritization** so teams know what to fix first
- **Three-level recommendations** for every finding: quick fix, proper fix, ideal state
- **Mobile-first analysis** with low-literacy audience considerations
- **AI-specific UX principles** for streaming interfaces, turn length, suggestion chips
- **Competitive UX benchmarking** against the user's reference apps

---

## How It Works

The review follows a five-phase process:

| Phase | What happens |
|-------|-------------|
| **1. Context** | Claude gathers structured inputs: north star metric, target user profile, reference apps, app identity, PRD (optional), analytics, known pain points |
| **2. Process** | Video frames are extracted at 1-second intervals (or screenshots are ingested). Every frame is reviewed — no sampling. A flow map is constructed with timing data |
| **3. Analyze** | Each screen is evaluated against 65+ UX laws. Flow-level analysis covers time-to-first-value, decision accumulation, behavioral mode, open loops, and peak/end experience |
| **4. Report** | An HTML report is generated with findings, evidence screenshots, priority matrix, current-vs-proposed design mockups, and UX law violation summary |
| **5. Write** | Findings are written to be brutal and specific — every issue connects to the north star metric, references exact screens, and includes an actionable fix |

If a PRD is provided, the review includes a hypothesis validation section that checks each product requirement against observed user behavior.

---

## Report Preview

The review produces a self-contained HTML file with a clean, brutalist design. Report sections include:

- **Hero / Cover** — app name with context cards (north star, target user, reference apps, device/connectivity)
- **Central Thesis** — 1-2 sentences identifying the fundamental UX problem
- **Executive Summary** — severity counts (critical / high / medium / low) with a visual flow map
- **PRD Validation** (when applicable) — pass/fail/warning checklist for each product hypothesis
- **Detailed Findings** — ordered by severity and north star impact, each with evidence screenshots, UX law tags, and recommendations
- **Priority Matrix** — sortable table: priority, issue, fix, severity, north star impact
- **Visual Design Recommendations** — side-by-side phone mockups showing current state vs. proposed changes, built in HTML/CSS
- **Time to First Value Analysis** — timeline with problem markers at each step
- **UX Laws Violated** — summary table mapping laws to specific findings

The report template uses Inter font, responsive grid layout, and severity-coded color system (critical red, high orange, medium yellow, low blue).

---

## Eagle Product Diagnostics

**Closes the loop between design intent, instrumented behavior, and actual outcomes.**

The UX review predicts what will break. Product Diagnostics proves whether it did — using your real analytics events and database outcomes.

The core question: **"Is the problem UX, behavior, or value?"**

Works with any analytics platform: Firebase, Mixpanel, Amplitude, Segment, CleverTap, Moengage, PostHog, Heap, or custom.

**Key capabilities:**

- **Three-layer triangulation** — validates findings across UX, analytics events, and database outcomes
- **Platform-agnostic** — accepts data from any analytics tool (CSV, JSON, dashboard screenshots, BigQuery exports, or plain text)
- **Per-feature verdicts** — PASS/FAIL/PARTIAL at each layer, with interpretation of disagreements
- **Funnel analysis** — maps events to screens, calculates conversion and drop-off at each step
- **Business impact quantification** — estimates revenue/retention/cost impact with calculations
- **Disagreement analysis** — explains what it means when UX says FAIL but data says PASS (or vice versa)
- **Data gap identification** — flags missing instrumentation that would strengthen the diagnosis

### The Three-Layer Model

```
Layer 1: DESIGN INTENT          "We believe users will do X"
         (UX review, PRD, hypothesis)
              |
Layer 2: INSTRUMENTED BEHAVIOR  "Users actually did Y"
         (Firebase, Mixpanel, Amplitude, Segment, etc.)
              |
Layer 3: OUTCOME TRUTH          "The database shows Z"
         (DB queries, business metrics, actual goal achievement)
```

**Verdict matrix — what each combination means:**

| UX | Events | DB | Diagnosis |
|----|--------|----|-----------|
| FAIL | FAIL | FAIL | Clear UX problem. Fix the interface. |
| FAIL | PASS | PASS | Users adapted despite bad UX. Monitor, lower priority. |
| PASS | FAIL | FAIL | Hidden problem: performance, content quality, or wrong audience. |
| PASS | PASS | FAIL | Value proposition problem, not UX. Strategy issue. |
| FAIL | FAIL | PASS | Power users pushing through friction. Mass market left behind. |

### Input Templates

To run Product Diagnostics, provide three inputs. Templates are included in the skill at `eagle-product-diagnostics/assets/input-templates/`:

#### 1. Goal Definition (`goal-definition.md`)

Define success for each feature:

```
Feature: Ask a farming question
User Story: As a farmer, I want to ask about my sick crop so I get treatment advice.
Success: User sends a query AND gets a useful response AND returns within 7 days.

Metric              Current    Target     Window
─────────────────────────────────────────────────
Queries/session     1.1        3+         per session
D7 retention        8%         20%        cohort
Task completion     35%        70%        per attempt
```

#### 2. Event Taxonomy (`event-taxonomy.md`)

Map your analytics events to screens and define funnels:

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

Works with: Firebase, Mixpanel, Amplitude, Segment, CleverTap, Moengage, PostHog, Heap, or any tool that exports events.

#### 3. Database Outcomes (`db-schema.md`)

Provide ground truth — actual metrics vs. targets:

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

**Cohort comparisons** are the most powerful input — comparing users who hit a specific UX condition vs. those who didn't:

```
                    Hit mode gate    Direct to chat    Difference
Queries/session     0.8              3.4               +325%
D7 retention        4%               22%               +18pp
```

---

## Installation

Install one or both skills. Symlink recommended for auto-updates.

### Option A: Symlink (recommended)

Keeps skills linked to this repo so you get updates with `git pull`:

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
ln -sf "$(pwd)/eagle-product-diagnostics" ~/.claude/skills/eagle-product-diagnostics
```

**Pros:** Updates automatically when you pull. Single source of truth.
**Cons:** Breaks if you move or delete the cloned repo.

### Option B: Copy

Standalone installation, independent of this repo:

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cp -r eagle-skills/eagle-ux-review ~/.claude/skills/
cp -r eagle-skills/eagle-product-diagnostics ~/.claude/skills/
```

**Pros:** No dependency on the cloned repo. Portable.
**Cons:** Manual re-copy needed to get updates.

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- `ffmpeg` and `ffprobe` — required for video input (frame extraction)
  ```bash
  # macOS
  brew install ffmpeg

  # Ubuntu/Debian
  sudo apt install ffmpeg
  ```

---

## Usage

Once installed, trigger skills with natural language in Claude Code:

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

**Two-skill workflow (most powerful):**
1. Run `eagle-ux-review` on screens/video to identify UX problems
2. Run `eagle-product-diagnostics` with the UX report + event data + DB outcomes to validate which problems actually impact metrics

Skills activate automatically when Claude detects matching intent.

---

## Built With

- **[Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's skill system for extending Claude with domain expertise via `SKILL.md` definitions
- **ffmpeg** — video frame extraction at configurable intervals (UX Review)
- **65+ UX laws** curated from established HCI research (Medhi et al., Nielsen, Gestalt, Fitts, etc.)
- **Three-layer triangulation framework** for validated product diagnostics

---

## Contributing

Contributions are welcome. Some areas where help is especially valuable:

- **New UX law categories** — additional principles with audit checklists
- **Report template improvements** — accessibility, print styles, dark mode
- **New skills** — other review types (accessibility, performance, API design) following the same pattern
- **Language/localization support** — report templates in other languages

To contribute:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test by installing the skill locally and running a review
5. Submit a pull request with a clear description of what changed and why

---

## License

MIT
