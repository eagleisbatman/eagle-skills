# Product Diagnostics Methodology

Core reference for triangulating UX review findings against analytics event data and database outcomes. Consult this document when performing any product diagnostics analysis.

---

## 1. The Three-Layer Validation Framework

Product diagnostics operates on the principle that no single data source tells the full story. Every feature assessment must triangulate across three independent layers.

### Layer 1: Design Intent

**Source:** UX review findings, PRD specifications, design hypotheses, competitive benchmarks.

This layer captures what was *supposed* to happen. It answers: Is the feature well-designed? Is the interaction pattern learnable? Are there friction points visible from inspection alone?

Design Intent findings are predictive. They identify *potential* problems based on heuristics, best practices, and pattern recognition. They do not confirm whether problems actually occur in production.

### Layer 2: Instrumented Behavior

**Source:** Analytics events, funnel data, click/tap tracking, session recordings, feature flags, A/B test allocations.

This layer captures what users *actually did*. It answers: Did users reach the feature? Did they complete the intended flow? Where did they abandon? How long did each step take?

Instrumented Behavior is observational but indirect. It shows that a button was tapped but not whether the resulting action succeeded. It shows drop-off but not the reason.

### Layer 3: Outcome Truth

**Source:** Database records, transaction logs, server-side metrics, revenue data, support tickets.

This layer captures what *actually happened* at the system level. It answers: Did the purchase complete? Did the message deliver? Did the account activate? Did the subscription renew?

Outcome Truth is the ground truth, but it lacks context. A completed purchase tells nothing about whether the experience was pleasant or whether the user will return.

### Why All Three Layers Are Required

| Layers Available | Blind Spot | Risk |
|---|---|---|
| Design Intent only | No evidence the predicted problems actually occur | Optimizing for theoretical issues while real ones go unaddressed |
| Instrumented Behavior only | No understanding of *why* users behave as they do, no confirmation actions succeeded | Misattributing drop-off causes; celebrating funnels that produce failed outcomes |
| Outcome Truth only | No visibility into the journey; cannot diagnose *where* or *how* things broke | Knowing revenue dropped but having no actionable path to fix it |
| Design Intent + Behavior | Cannot confirm whether completed flows actually produced real outcomes | Users "complete" a checkout but payments silently fail |
| Design Intent + Outcome | Cannot see the journey; only know intent and result | Feature works for completers but 80% of users never find it |
| Behavior + Outcome | No framework for *why* the design fails; fixes are guesswork | Data shows the problem but solutions are shots in the dark |

All three layers together create a closed loop: hypothesize (Design Intent), observe (Behavior), verify (Outcome). Skip any layer and the diagnosis is incomplete.

---

## 2. Per-Feature Goal Definition Framework

Before evaluating any feature, define what success looks like. Without explicit goals, diagnostics devolves into opinion.

### Goal Types

| Goal Type | Definition | Primary Metric | Example |
|---|---|---|---|
| **Conversion** | User completes a target action | Completion rate | Checkout completion, signup, upgrade |
| **Engagement** | User interacts meaningfully with the feature | Frequency, depth, DAU/MAU ratio | Messages sent, searches performed, content created |
| **Retention** | User returns to the feature over time | D1/D7/D30 retention, churn rate | Weekly active usage, subscription renewal |
| **Efficiency** | User accomplishes a task faster or with less effort | Time-on-task, steps-to-complete, error rate | Form completion time, support ticket reduction |
| **Satisfaction** | User perceives the experience positively | NPS, CSAT, rating, qualitative feedback | In-app rating, survey response, review sentiment |

### Applying SMART Criteria

Every feature goal must be:

- **Specific:** Name the exact metric and the user segment it applies to.
- **Measurable:** Confirm the metric can be computed from available data sources (Layer 2 or Layer 3).
- **Achievable:** Ground the target in baseline data or industry benchmarks, not aspiration.
- **Relevant:** Tie the goal to a business outcome the stakeholder cares about.
- **Time-bound:** Specify the evaluation window (e.g., "within 14 days of launch," "over a 30-day rolling window").

### Goal Examples by App Type

| App Type | Feature | Goal Type | Goal Statement |
|---|---|---|---|
| E-commerce | Product detail page redesign | Conversion | Increase add-to-cart rate from 12% to 15% within 30 days of rollout |
| Chat / AI | Response streaming UI | Engagement | Increase average conversation length from 3.2 to 4.5 turns within 14 days |
| Marketplace | Seller onboarding flow | Efficiency | Reduce median onboarding time from 22 min to 12 min; increase completion from 41% to 60% |
| SaaS tool | Dashboard customization | Retention | Users who customize dashboards retain at D30 at 72% vs 58% baseline |
| Content platform | Recommendation carousel | Engagement | Increase content-start rate from carousel by 20% relative; maintain D7 retention |

When goals are undefined or vague, flag this as a diagnostic blocker. Findings without goals are observations, not verdicts.

---

## 3. Event-to-Flow Mapping Process

### Step 1: Identify the UI Flow

Break the feature into discrete screens or steps as experienced by the user. Use the UX review or design specs as the source. Number each step sequentially.

Example for a checkout flow:
1. Cart review screen
2. Shipping address entry
3. Payment method selection
4. Order confirmation tap
5. Confirmation/receipt screen

### Step 2: Map Events to Steps

For each UI step, identify the analytics event(s) that fire. Create a mapping table:

| Step | Screen/Action | Expected Event(s) | Event Exists? | Notes |
|---|---|---|---|---|
| 1 | Cart review | `cart_viewed` | Yes | |
| 2 | Shipping entry | `shipping_started`, `shipping_completed` | Partial | No `shipping_started` event; only completion |
| 3 | Payment selection | `payment_method_selected` | Yes | |
| 4 | Confirm tap | `order_submitted` | Yes | |
| 5 | Receipt screen | `order_confirmed` | No | Server-side `order_created` exists in DB only |

### Step 3: Build the Funnel Definition

Arrange the events in sequence. Define the funnel as an ordered list of events with these parameters:

- **Entry event:** The first event in the sequence.
- **Exit event:** The final event representing success.
- **Time window:** Maximum allowed time between entry and exit (e.g., 60 minutes).
- **Uniqueness:** Per-user-per-session, per-user-per-day, or per-user-lifetime.

### Step 4: Calculate Key Metrics

For each consecutive pair of steps:

- **Step conversion rate:** Users reaching step N+1 / Users reaching step N
- **Cumulative conversion rate:** Users reaching step N / Users reaching step 1
- **Drop-off rate:** 1 - step conversion rate
- **Median time between steps:** Median of (timestamp_N+1 - timestamp_N) for users who completed both

Flag any step where:
- Drop-off exceeds 30% (or exceeds the historical baseline by more than 10 percentage points)
- Median time between steps exceeds 2x the expected interaction time
- The event volume at a step is anomalously low relative to the previous step

### Step 5: Handle Instrumentation Gaps

When events are missing for a UI step:

1. **Document the gap** explicitly in the mapping table.
2. **Check for proxy events:** Is there a server-side log, error event, or page-view that covers the gap?
3. **Assess the impact on analysis:** Can the funnel still be evaluated, or is the gap a blind spot that blocks a verdict?
4. **Recommend instrumentation:** Specify the event name, properties, and trigger point needed to close the gap.

Never interpolate or assume conversion through an unmeasured step. Mark those transitions as "unmeasured" in the funnel and note the gap in the final report.

---

## 4. The Verdict Matrix

Every feature assessment produces a three-layer verdict: PASS or FAIL for each layer. This yields 8 possible combinations. Use this matrix to diagnose the pattern and determine the correct action.

| # | UX (Design) | Events (Behavior) | DB (Outcome) | Diagnosis | Example | Action | Common Misinterpretation |
|---|---|---|---|---|---|---|---|
| 1 | PASS | PASS | PASS | **Validated Success.** Feature works as designed, users complete the flow, outcomes are real. | Well-designed checkout with 68% funnel completion and matching order records in DB. | Monitor for regression. Set alerting thresholds. Move to next priority. | Assuming success is permanent; neglecting to set monitoring baselines. |
| 2 | PASS | PASS | FAIL | **Silent Failure.** Users complete the UI flow but the backend does not produce the expected outcome. | Users tap "Subscribe" and see a success screen, but payment processor rejects 30% of charges. | Investigate server-side failures immediately. This is a revenue/trust emergency. Cross-reference event timestamps with error logs. | Treating this as a UX problem. The UI is fine; the system behind it is broken. |
| 3 | PASS | FAIL | PASS | **Hidden Path.** The designed flow has poor adoption or completion, but outcomes still occur through an alternative route. | Onboarding wizard has 25% completion, but users skip it and self-serve successfully via docs/settings. | Evaluate whether the alternative path is sustainable. If so, simplify or remove the wizard. If not, investigate why the designed flow is abandoned. | Celebrating the outcome without realizing the intended feature is unused. |
| 4 | PASS | FAIL | FAIL | **Good Design, No Traction.** The design is sound on paper but users do not engage, and outcomes do not materialize. | A well-designed referral program that nobody discovers because it is buried three levels deep. | Investigate discoverability, entry points, and user awareness. The design may be good but the placement, timing, or motivation is wrong. | Redesigning the feature itself when the problem is exposure, not design quality. |
| 5 | FAIL | PASS | PASS | **Ugly but Functional.** Design has clear issues, yet users push through and succeed anyway. | A form with poor validation feedback and confusing labels, but experienced/motivated users complete it and data lands correctly. | Improve the design to reduce friction. Current success likely depends on highly motivated users; broader audiences will not tolerate the friction. Quantify the addressable drop-off. | Deprioritizing the fix because "it works." Survivorship bias masks the users who gave up. |
| 6 | FAIL | PASS | FAIL | **Deceptive Funnel.** Users navigate a flawed UI and appear to complete the flow, but outcomes fail. | Confusing toggle states cause users to think they enabled a setting (event fires) but the wrong value is written to the database. | Fix the UX flaw *and* audit the data pipeline. The UI confusion is causing bad data to flow downstream. High urgency. | Fixing only the backend without addressing the UX root cause that generates bad input. |
| 7 | FAIL | FAIL | PASS | **Accidental Success.** Design is poor, users struggle, yet somehow outcomes exist. Investigate for data artifacts. | DB shows "completed profiles" but many are default/empty values auto-populated by the system, not genuine user completions. | Audit the Outcome Truth data for false positives. Verify that DB records represent genuine user-driven outcomes, not system defaults, test data, or edge cases. | Taking DB records at face value without validating they represent real user intent. |
| 8 | FAIL | FAIL | FAIL | **Total Failure.** Nothing works. Design is flawed, users do not engage, outcomes do not occur. | A new feature launched with broken analytics, confusing UI, and a backend bug preventing data writes. | Triage: fix instrumentation first (to gain visibility), then address the most impactful UX blocker, then verify outcomes. Do not attempt to optimize what cannot yet be measured. | Trying to fix everything at once instead of sequencing: measure, then diagnose, then fix. |

### Applying the Matrix

1. Evaluate each layer independently before looking at the combination.
2. Assign PASS/FAIL based on the feature's defined goals (Section 2), not gut feeling.
3. Look up the combination in the matrix.
4. Validate the diagnosis against the specific data before accepting it. The matrix provides a starting hypothesis, not an automatic conclusion.

---

## 5. Statistical Considerations

### Sample Size Requirements

Do not issue definitive verdicts on small samples. Use these thresholds as minimums:

| Metric Type | Minimum Sample | Confidence Level | Notes |
|---|---|---|---|
| Conversion rate (binary) | 400 per variant | 95% | Assumes ~5% baseline rate; higher baselines need fewer samples |
| Funnel step transition | 200 per step | 90% | Per-step, not total funnel entry |
| Time-on-task (continuous) | 100 per segment | 90% | High variance in timing data; check for outliers |
| Retention (D7, D30) | 500 per cohort | 95% | Must have full maturation window for each user |
| Revenue impact | 1000 per variant | 95% | Revenue distributions are heavy-tailed; use bootstrapping |

When sample sizes fall below these thresholds, label findings as **"directional only"** and state the sample size explicitly. Never present directional findings with the same confidence language as statistically significant ones.

### Cohort Analysis

Compare users who experienced the feature against those who did not. Control for:

- **Selection bias:** Users who opt into a feature may differ systematically from those who do not. Note this limitation.
- **Time of exposure:** Compare cohorts from the same time period. A cohort from launch week behaves differently than a cohort from week 4.
- **Platform:** Mobile vs. desktop vs. tablet users have different baseline behaviors.

### Time-Window Considerations

- Do not compare weekday data to weekend data without normalization.
- Account for seasonality (end-of-month, holidays, paydays) when evaluating conversion or revenue metrics.
- Specify the exact date range for every metric cited. Unanchored metrics ("our conversion rate is 12%") are meaningless.
- For retention metrics, ensure every user in the cohort has had enough calendar time to reach the retention milestone. A D30 retention number computed 15 days after launch is invalid.

### Segmentation

Always check whether aggregate metrics mask segment-level divergence. Minimum segmentation dimensions:

- **Platform:** iOS, Android, Web, API
- **Geography:** At minimum, country-level; timezone-aware for time-based metrics
- **User cohort:** New vs. returning; free vs. paid; acquisition channel
- **Feature variant:** If A/B tested, by variant allocation

Report the aggregate *and* any segment where the verdict would differ from the aggregate. A feature that PASSes overall but FAILs for mobile users requires a segment-specific verdict.

---

## 6. Business Impact Quantification

### Estimating Impact

For every validated finding (a verdict from the matrix with sufficient data), estimate the business impact using this structure:

1. **Reach:** How many users per time period are affected? Use event data or DB counts.
2. **Impact:** What is the per-user effect? (e.g., $X lost revenue per failed checkout, Y minutes wasted per broken flow)
3. **Confidence:** How certain is the finding? (Conclusive / Directional / Hypothetical)
4. **Effort:** Estimated implementation effort to resolve. (T-shirt size: S/M/L/XL or story points if available)

### RICE Scoring

Rank findings by priority using:

```
RICE Score = (Reach x Impact x Confidence) / Effort
```

| Factor | Scale | Definition |
|---|---|---|
| Reach | Users/month affected | Raw count or percentage of MAU |
| Impact | 0.25 (minimal), 0.5 (low), 1 (medium), 2 (high), 3 (critical) | Effect on the user if fixed |
| Confidence | 0.5 (hypothetical), 0.8 (directional), 1.0 (conclusive) | Statistical and evidentiary backing |
| Effort | Person-weeks | Engineering estimate; default to 1 if unknown |

### Business Impact Statement Template

Use this format for each finding in the final report:

```
[FINDING ID]: [One-sentence description]
Verdict: [Matrix pattern, e.g., PASS/FAIL/PASS - Hidden Path]
Reach: [N users/month]
Impact: [Quantified effect per user]
Estimated Annual Value: [Reach x Impact x 12, or relevant annualization]
Confidence: [Conclusive | Directional | Hypothetical]
Recommended Action: [One sentence]
RICE Score: [Computed value]
```

### Connecting to Revenue

Where possible, translate findings into dollar estimates:

- **Lost conversion:** (Drop-off count) x (Average order value) x (Estimated recovery rate if fixed)
- **Efficiency gain:** (Time saved per user per task) x (Users per month) x (Hourly cost or value of user time)
- **Retention impact:** (Users at risk of churn) x (LTV) x (Estimated retention lift)
- **Support cost reduction:** (Tickets attributable to issue) x (Cost per ticket)

State assumptions explicitly. Rough estimates with stated assumptions are more useful than precise numbers built on hidden ones.

---

## 7. Disagreement Analysis

When layers contradict each other, the disagreement is the finding. Do not resolve contradictions by discarding a layer. Instead, investigate the disagreement itself.

### Investigation Checklist by Disagreement Pattern

**UX says FAIL, Behavior says PASS:**
- [ ] Are the analytics events accurately capturing the intended interaction, or are they firing on partial/unintended actions?
- [ ] Is the UX issue real but compensated by user workarounds (e.g., users learn to avoid the broken part)?
- [ ] Is the UX review applying standards mismatched to the audience (e.g., expert users tolerating complexity)?
- [ ] Check session recordings or heatmaps for qualitative evidence of struggle despite completion.

**Behavior says PASS, Outcome says FAIL:**
- [ ] Is there a server-side failure between the client event and the database write?
- [ ] Are there race conditions, timeouts, or retries creating phantom successes?
- [ ] Does the event fire before the action completes (optimistic tracking)?
- [ ] Check error logs for the time window matching the behavior data.

**UX says PASS, Behavior says FAIL:**
- [ ] Is the feature discoverable? Check entry-point visibility and navigation paths.
- [ ] Is the feature gated behind permissions, feature flags, or eligibility criteria that limit reach?
- [ ] Is the event instrumentation correct? A missing or misconfigured event looks like zero engagement.
- [ ] Was the feature launched with sufficient announcement, onboarding, or contextual nudges?

**UX says PASS, Outcome says FAIL:**
- [ ] Is there a backend or infrastructure issue independent of the UI?
- [ ] Are third-party dependencies (payment processors, APIs, CDNs) failing intermittently?
- [ ] Is the success criteria for Outcome Truth correctly defined, or is the query wrong?

**All three layers disagree with each other:**
- [ ] Revalidate the data sources. At least one layer likely has a measurement error.
- [ ] Check that all three layers are examining the same user population, time window, and feature version.
- [ ] Present the disagreement transparently and recommend focused investigation before issuing a verdict.

### Presenting Uncertainty

When layers conflict and the investigation does not resolve the disagreement:

- State the conflict explicitly: "Layer 2 indicates X, but Layer 3 indicates Y."
- Present the most likely explanation and the confidence level in that explanation.
- List what additional data or investigation would resolve the conflict.
- Never force a clean narrative. Stakeholders are better served by an honest "we don't know yet, and here is what we need" than by a fabricated conclusion.

---

## 8. Quality Checks

Run this checklist before delivering any diagnostics report. Every item must be satisfied or explicitly noted as an exception.

### Data Integrity
- [ ] All metrics cite a specific date range.
- [ ] Sample sizes are stated for every quantitative claim.
- [ ] Findings below minimum sample thresholds are labeled "directional only."
- [ ] Event definitions have been verified against the tracking plan or codebase (not just event names assumed from context).
- [ ] DB queries have been reviewed for correctness (joins, filters, time zones, deduplication).

### Completeness
- [ ] Every feature under review has a defined goal (Section 2).
- [ ] Every feature has been evaluated across all three layers, or gaps are explicitly documented.
- [ ] The event-to-flow mapping (Section 3) is included or referenced.
- [ ] Instrumentation gaps are listed with recommended events to add.

### Verdict Accuracy
- [ ] Each verdict matches a pattern in the Verdict Matrix (Section 4).
- [ ] Layer assessments (PASS/FAIL) are justified with specific data, not summary judgment.
- [ ] Disagreements between layers are analyzed (Section 7), not silently resolved.
- [ ] Confounding factors (seasonality, platform mix, concurrent launches) are addressed.

### Business Impact
- [ ] At least one finding includes a quantified business impact estimate.
- [ ] Assumptions behind impact estimates are stated explicitly.
- [ ] Findings are prioritized (RICE or equivalent), not presented as an unranked list.
- [ ] Recommended actions are specific and actionable, not generic ("improve the UX").

### Report Hygiene
- [ ] No findings rely solely on a single layer.
- [ ] Segment-level breakdowns are included where the aggregate masks divergence.
- [ ] The report distinguishes between "the feature is broken" and "we cannot measure the feature."
- [ ] All acronyms and metric names are defined on first use.
- [ ] The executive summary (if included) matches the detailed findings; no claims appear in the summary that are unsupported in the body.

---

*End of methodology reference.*
