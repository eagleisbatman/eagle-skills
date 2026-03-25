---
name: eagle-product-diagnostics
description: "This skill should be used when the user asks to validate UX findings against real data, triangulate product metrics, diagnose why a feature isn't hitting its goals, connect Firebase/Mixpanel/Amplitude events to UX problems, analyze event funnels against design intent, check if a product hypothesis passed or failed using data, or correlate drop-offs with UX issues. Trigger phrases include: 'validate these findings', 'why isn't this metric moving', 'triangulate UX and data', 'product diagnostics', 'check events against UX', 'is this feature working', 'funnel analysis', 'metric validation', 'connect analytics to UX', 'why are users dropping off', 'compare DB outcomes to UX', 'event-to-screen mapping'. Also trigger when the user provides analytics exports, event schemas, or database samples alongside UX review findings or product goals."
---

# Eagle Product Diagnostics

## Overview

Closes the loop between design intent, instrumented behavior, and actual outcomes. Takes a UX review (or product hypothesis), analytics event data, and database outcomes — then produces a triangulated validation report showing which features are working, which are broken, and where the real bottleneck is.

The core question this skill answers: **"Is the problem UX, behavior, or value?"**

This skill is the natural companion to `eagle-ux-review`. The UX review predicts what will break; this skill proves whether it did.

## Three-Layer Validation Model

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

## Process

### Phase 1: Gather Inputs

Present all questions in one message. Provide the input templates from `assets/input-templates/` if the user needs structure.

**Required Inputs:**

1. **Goal Definitions** — Per-feature success criteria. Template: `assets/input-templates/goal-definition.md`
   - Feature name
   - What "success" means for this feature
   - Target metric and threshold
   - North star connection

2. **Event Data** — From any analytics platform. Template: `assets/input-templates/event-taxonomy.md`
   - Event names mapped to screens/actions
   - Funnel definitions (ordered event sequences)
   - Conversion rates or raw event counts
   - Accepted formats: CSV export, JSON schema, screenshot of funnel dashboard, or plain-text event list

3. **Outcome Data** — Database results or business metrics. Template: `assets/input-templates/db-schema.md`
   - Query results showing actual user achievement vs. targets
   - Cohort data if available (e.g., users who hit feature X vs. those who didn't)
   - Retention/revenue/engagement numbers

**Optional but high-value:**
- **UX Review Report** — Output from `eagle-ux-review`. Enables direct finding-to-event mapping.
- **A/B Test Results** — If variants exist, compare UX paths against metric outcomes.
- **Support Tickets / User Feedback** — Qualitative signal to triangulate with quantitative.
- **Session Recordings** — From Hotjar, FullStory, LogRocket, etc.

**Read `references/analytics-platforms.md`** for platform-specific guidance on extracting event data from Firebase, Mixpanel, Amplitude, Segment, Moengage, CleverTap, PostHog, Heap, and others.

If the user says "just analyze it" with partial data, work with what's available but **explicitly flag which layers are missing** and how that limits the diagnosis.

### Phase 2: Map Events to Flows

Build an event-to-screen mapping:

```
Screen/Step              Event(s)                    Expected Behavior
---------------------------------------------------------------------
App Open                 app_open, session_start     100% (baseline)
Home Screen              screen_view:home            High (>90%)
Feature Entry            screen_view:feature_entry   Target: >60% of home viewers
Core Action Started      core_action_started         Target: >80% of feature entrants
Core Action Completed    core_action_completed       Should be ~100% of starts
Follow-up / Repeat       core_action_started (2nd)   Target: >40%
```

For each step, calculate:
- **Absolute conversion** from baseline (app open)
- **Step-to-step conversion** (what % proceed to next step)
- **Drop-off rate** at each step
- **Time between events** (if timestamps available)

### Phase 3: Triangulate

For each feature/goal, produce a three-layer verdict:

**Read `references/methodology.md`** for the full triangulation framework, verdict matrix, and interpretation guide.

| Layer | Source | Question | Verdict |
|-------|--------|----------|---------|
| Design Intent | UX review / PRD | Does the UX support this goal? | PASS / FAIL / PARTIAL |
| Behavior | Event data | Are users doing what we expected? | PASS / FAIL / PARTIAL |
| Outcome | DB data | Is the goal actually being achieved? | PASS / FAIL / PARTIAL |

**Interpretation matrix:**

| UX | Events | DB | Diagnosis |
|----|--------|----|-----------|
| FAIL | FAIL | FAIL | Clear UX problem. Fix the interface. |
| FAIL | PASS | PASS | Users adapted despite bad UX. Monitor, lower priority. |
| PASS | FAIL | FAIL | Hidden problem: performance, content quality, wrong audience. |
| PASS | PASS | FAIL | Value proposition problem, not UX. Strategy issue. |
| FAIL | FAIL | PASS | Power users pushing through. Mass market left behind. |

### Phase 4: Generate Report

**Always produce an HTML file.** Use the structure from `assets/report-template.html`.

**Required Report Sections:**

1. **Cover** — Product name, review scope, data sources used, date
2. **Input Summary** — What data was provided, what's missing, confidence level
3. **Goal Scorecard** — Table of all features/goals with three-layer PASS/FAIL/PARTIAL verdicts
4. **Funnel Analysis** — Per-flow event funnel with conversion rates and drop-off markers
5. **Finding Validation** — If UX review provided: each UX finding mapped to event data and DB outcome
6. **Diagnosis by Feature** — Per-feature deep dive with all three layers, interpretation, and recommended action
7. **Disagreement Analysis** — Where layers disagree and what that means
8. **Metric Impact Quantification** — Business impact estimates with calculations
9. **Recommended Actions** — Prioritized by validated impact (not just UX severity)
10. **Data Gaps** — What additional instrumentation or data would strengthen the diagnosis

### Phase 5: Writing Principles

- **Let the data speak.** Don't force a UX narrative if the numbers tell a different story.
- **Flag uncertainty.** Small sample sizes, missing events, and single-source verdicts should be called out.
- **Distinguish correlation from causation.** "Users who skip step X have 3x retention" does not prove step X causes churn — but it's strong evidence.
- **Quantify everything.** "Drop-off is high" is weak. "47% of users abandon at step 3, costing an estimated 2,400 conversions/month" is actionable.
- **Challenge the hypothesis.** If the data says the UX is fine but the metric is failing, say so. The problem might be content quality, market fit, or technical reliability.
- **Connect to money/impact.** Every validated finding should estimate business impact where possible.

## Key Anti-Patterns

1. **Phantom Funnel** — Events exist but don't map to actual user intent (tracking pageviews, not actions)
2. **Vanity Metrics** — Tracking MAU when the real question is task completion rate
3. **Missing Middle** — Events at start and end of funnel but nothing in between
4. **Silent Failures** — Errors that aren't instrumented (API failures, timeouts, empty responses)
5. **Survivorship Bias** — Only analyzing users who completed the flow, ignoring drop-offs
6. **Attribution Confusion** — Multiple features affecting the same metric with no way to isolate
7. **Stale Baselines** — Comparing against targets set before a major product change
8. **Platform Blindness** — Not segmenting by iOS/Android/web when behavior differs dramatically

## Resources

### Reference Files
- **`references/methodology.md`** — Full triangulation framework, verdict matrix, interpretation guide, statistical considerations, business impact quantification
- **`references/analytics-platforms.md`** — Platform-specific guidance for Firebase, Mixpanel, Amplitude, Segment, Moengage, CleverTap, PostHog, Heap. Event export formats, common schemas, funnel setup

### Assets
- **`assets/report-template.html`** — HTML/CSS template for the diagnostics report
- **`assets/input-templates/goal-definition.md`** — Template for per-feature goal definitions
- **`assets/input-templates/event-taxonomy.md`** — Template for event schema and funnel definitions
- **`assets/input-templates/db-schema.md`** — Template for database outcome data

## Notes

- This skill works best as a follow-up to `eagle-ux-review`, but can operate standalone with just goals + event data + DB data.
- Platform-agnostic: works with any analytics tool that can export event data.
- For apps without analytics instrumentation, the skill can recommend what events to add based on the goal definitions.
- Statistical significance matters: flag findings from small samples. A 50-user sample showing 60% drop-off is directional; a 5,000-user sample is conclusive.
- When UX review and data disagree, the data wins — but investigate why the UX review missed it.
