# Event Taxonomy Template

Provide your analytics event structure so we can map user behavior to product goals. Works with any platform (Firebase, Mixpanel, Amplitude, Segment, CleverTap, Moengage, PostHog, Heap, or custom).

---

## Analytics Platform

**Platform:** [e.g., Firebase Analytics, Mixpanel, Amplitude, PostHog]
**Data access:** [e.g., BigQuery export, dashboard screenshots, CSV export, API]
**Date range:** [e.g., 2026-01-01 to 2026-03-25]
**Total users in sample:** [e.g., 12,400]

---

## Event List

List all tracked events relevant to the features being validated. Include event name, what triggers it, and any key parameters.

| Event Name | Trigger | Key Parameters | Screen/Step |
|-----------|---------|---------------|-------------|
| `app_open` | App launched | `source` (organic/push/deeplink) | -- |
| `screen_view` | Screen displayed | `screen_name`, `screen_class` | varies |
| `onboarding_start` | First onboarding screen shown | `variant` | Onboarding |
| `onboarding_complete` | Last onboarding step done | `duration_seconds`, `steps_completed` | Onboarding |
| `feature_entry` | User enters a key feature | `entry_point`, `feature_name` | varies |
| `core_action_started` | User initiates the primary action | `action_type`, `context` | varies |
| `core_action_completed` | Primary action completes successfully | `duration_ms`, `result_status` | varies |
| `cta_tapped` | User taps a call-to-action | `cta_label`, `position`, `screen_name` | varies |
| `error_displayed` | Error shown to user | `error_type`, `error_code` | varies |
| `session_end` | Session terminated | `session_duration`, `screens_viewed`, `actions_completed` | -- |

*(Add or remove rows as needed. The above is a generic starting point — adapt event names to your product.)*

---

## Funnel Definitions

Define the key funnels (ordered event sequences) you want analyzed.

### Funnel 1: [Name — e.g., "First Purchase Funnel", "Onboarding Completion", "Search-to-Result"]

**Goal:** [What this funnel measures — e.g., "Can a new user complete their first purchase?", "Do users finish onboarding?", "Do searches produce useful results?"]

| Step | Event | Expected Conversion |
|------|-------|-------------------|
| 1 | `app_open` | 100% (baseline) |
| 2 | `screen_view` (home) | >95% |
| 3 | `feature_entry` | >60% |
| 4 | `core_action_started` | >80% of step 3 |
| 5 | `core_action_completed` | >95% of step 4 |

**Actual conversion rates (if known):**
- Step 1→2: [X%]
- Step 2→3: [X%]
- Step 3→4: [X%]
- Step 4→5: [X%]
- Overall (Step 1→5): [X%]

### Funnel 2: [Name]

*(Copy the funnel template above for each additional funnel)*

---

## Segments (Optional)

If you can break down event data by segments, list them:

| Segment | Definition | Size |
|---------|-----------|------|
| New users | First 7 days | [n] |
| Returning users | Day 8+ | [n] |
| Android | Platform = Android | [n] |
| iOS | Platform = iOS | [n] |
| Organic | Acquisition = organic | [n] |
| [Custom segment] | [definition] | [n] |

---

## How to Export This Data

**If you're not sure what to provide, any of these works:**

1. **Dashboard screenshot** — Screenshot your funnel view in Firebase/Mixpanel/Amplitude. We'll read the numbers.
2. **CSV export** — Export events for the date range. Most platforms support this from the Events tab.
3. **BigQuery SQL result** — If your events land in BigQuery, run a query and paste the result.
4. **Plain text** — Just list event names and approximate conversion rates. Even rough numbers help.
5. **Event schema JSON** — If you have a tracking plan document, share it.

The more complete the data, the more precise the diagnosis. But partial data is far better than no data.
