# Analytics Platforms Reference

Reference for extracting and interpreting event data from major analytics platforms. Used during UX validation to cross-reference findings against real user behavior.

---

## Firebase Analytics (Google Analytics for Firebase)

The default analytics layer for most mobile apps. Events auto-log on SDK init. Data lives in Google Analytics 4 (GA4) but is accessed through Firebase Console or BigQuery.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **Firebase Console** | Analytics > Events > select event > Export CSV (top-right) |
| **BigQuery Export** | Project Settings > Integrations > BigQuery > enable daily/streaming export. Tables land in `analytics_<property_id>.events_*` |
| **GA4 API** | Use the GA4 Data API (`runReport` endpoint). Requires OAuth2 or service account. |
| **Google Sheets add-on** | GA4 add-on can pull reports directly into sheets |

### Event Schema

```json
{
  "event_name": "screen_view",
  "event_timestamp": 1695000000000000,
  "user_pseudo_id": "abc123",
  "event_params": [
    { "key": "firebase_screen", "value": { "string_value": "HomeScreen" } },
    { "key": "engagement_time_msec", "value": { "int_value": 5200 } }
  ],
  "device": { "category": "mobile", "operating_system": "Android" },
  "geo": { "country": "US" }
}
```

Event params are key-value pairs nested inside `event_params` array. This is the BigQuery schema; CSV exports flatten it.

### Funnel Extraction

- **Firebase Console**: Analytics > Funnels (limited, 10 steps max)
- **GA4 Console**: Explore > Funnel exploration (more flexible, supports open/closed funnels)
- **BigQuery**: Query `events_*` tables, filter by `event_name`, join on `user_pseudo_id`, order by `event_timestamp`

### Typical Mobile App Events

`first_open`, `session_start`, `screen_view`, `select_content`, `add_to_cart`, `begin_checkout`, `purchase`, `app_exception`, `ad_click`, `login`, `sign_up`

### Gotchas

- Events take **4-8 hours** to appear in Firebase Console; BigQuery streaming export is near-real-time.
- Auto-collected events (`first_open`, `session_start`, `screen_view`) cannot be disabled.
- Event names are **case-sensitive** and limited to **500 distinct events** per property.
- Custom parameters are limited to **25 per event** for reporting (unlimited in BigQuery).
- BigQuery export uses **microsecond timestamps**, not milliseconds.

---

## Mixpanel

Event-centric analytics with strong funnel and retention tooling. Popular with product teams.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **UI Export** | Insights/Funnels report > kebab menu > Export CSV/PNG |
| **Raw Data Export API** | `GET /api/2.0/export` with `from_date`, `to_date`. Returns JSONL (one JSON object per line). Requires service account. |
| **Data Pipelines** | Settings > Data Pipelines > export to S3, GCS, BigQuery, Snowflake on schedule |

### Event Schema

```json
{
  "event": "button_tap",
  "properties": {
    "time": 1695000000,
    "distinct_id": "user_456",
    "$device": "iPhone 14",
    "$os": "iOS",
    "$screen_name": "CheckoutScreen",
    "button_label": "Pay Now"
  }
}
```

All properties are flat key-value pairs under `properties`. System properties are prefixed with `$`.

### Funnel Extraction

- **UI**: Create Funnels report > add steps by event name > set conversion window > view drop-off
- **API**: Use the Funnels query API (`/api/2.0/funnels`) with `funnel_id`
- Supports **hold property constant** (e.g., same item across steps)

### Typical Mobile App Events

`App Open`, `Screen View`, `Button Tap`, `Sign Up`, `Login`, `Search`, `Item Viewed`, `Add to Cart`, `Checkout Started`, `Purchase Complete`, `Error Shown`

### Gotchas

- Mixpanel uses **distinct_id** for identity. Anonymous and identified users must be merged via `$identify` / `alias`.
- Default timezone is **US/Pacific** unless changed in project settings.
- Raw export API returns **JSONL**, not valid JSON array. Each line is a separate JSON object.
- Free tier retains data for **90 days** only.

---

## Amplitude

Behavioral analytics with heavy focus on cohort analysis and experimentation. Common in mid-to-large product orgs.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **UI Export** | Any chart > Export > CSV |
| **Export API** | `GET /api/2/export` with `start`/`end` (hourly zipped JSON files). Requires API key + secret. |
| **Snowflake/BigQuery** | Available on Growth/Enterprise plans via Amplitude Data |
| **Cohort Export** | Cohorts > select > Export CSV |

### Event Schema

```json
{
  "event_type": "screen_view",
  "event_time": "2024-01-15 10:30:00.000",
  "user_id": "user_789",
  "device_id": "device_abc",
  "event_properties": { "screen_name": "ProfileScreen" },
  "user_properties": { "plan": "premium", "signup_date": "2023-06-01" },
  "platform": "iOS",
  "os_name": "ios",
  "country": "India"
}
```

Note the split between `event_properties` and `user_properties`.

### Funnel Extraction

- **UI**: New > Funnel Analysis > add events as steps > set conversion window
- Supports **holding property constant**, **segmentation by cohort**, and **time-to-convert histograms**
- **API**: Use the Dashboard REST API or the new Analytics API (v2)

### Typical Mobile App Events

`session_start`, `screen_view`, `button_click`, `signup_completed`, `login`, `search_performed`, `item_viewed`, `add_to_cart`, `checkout_initiated`, `purchase`, `error_encountered`

### Gotchas

- Amplitude has **both** `user_id` and `device_id`. If `user_id` is null, `device_id` is used for identity.
- Export API returns **zipped JSON files per hour**. Must unzip before parsing.
- Event volume limits on free tier (**10M events/month**).
- Amplitude merges anonymous + identified users automatically via device_id mapping, which can cause identity issues if not managed.

---

## Segment

Not an analytics platform itself. Segment is a **Customer Data Platform (CDP)** that collects events and routes them to destinations (Mixpanel, Amplitude, BigQuery, etc.).

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **Connections > Debugger** | Real-time event stream visible in Segment UI (not exportable at scale) |
| **Warehouses** | Segment writes to Snowflake, BigQuery, Redshift, Postgres. Query directly. |
| **Replay** | Replay historical data to a new destination |
| **Protocols / Tracking Plans** | Export the tracking plan as JSON for schema reference |

### Event Schema (Segment Spec)

```json
{
  "type": "track",
  "event": "Order Completed",
  "userId": "user_101",
  "anonymousId": "anon_xyz",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "properties": {
    "order_id": "ORD-123",
    "revenue": 49.99,
    "currency": "USD"
  },
  "context": {
    "device": { "type": "ios" },
    "app": { "name": "MyApp", "version": "2.1.0" }
  }
}
```

Segment uses a **standardized spec** with call types: `identify`, `track`, `page`/`screen`, `group`, `alias`.

### Funnel Extraction

Segment does not provide funnel analysis. Funnels are built in the downstream destination (Amplitude, Mixpanel, BigQuery, etc.).

### Typical Events (Segment E-Commerce Spec)

`Product Viewed`, `Product Added`, `Cart Viewed`, `Checkout Started`, `Order Completed`, `Application Opened`, `Screen Viewed`, `Signed Up`, `Logged In`

### Gotchas

- Segment **transforms and routes** data. The event may look different in the destination than in Segment due to destination-specific mappings.
- `anonymousId` is always present; `userId` is only set after identification.
- Warehouse schema uses **one table per event type** by default (`tracks`, `pages`, `screens`, plus one table per event name).
- Historical replays can cause **duplicate events** in destinations if idempotency is not handled.

---

## CleverTap

Popular in India and Southeast Asia. Combines analytics with engagement (push, in-app, email). Strong real-time segmentation.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **Dashboard** | Analytics > Events > select event > Download CSV |
| **Export API** | `POST /1/export/events.json` with date range. Returns paginated JSON. Requires account ID + passcode. |
| **S3 Export** | Settings > Data Export > configure S3 bucket for daily dumps |

### Event Schema

```json
{
  "eventName": "Product Viewed",
  "ts": 1695000000,
  "identity": "user@email.com",
  "objectId": "event_id_abc",
  "eventProperties": {
    "product_id": "SKU-100",
    "screen": "ProductDetailScreen"
  },
  "profileProperties": {
    "Name": "Alice",
    "Phone": "+919876543210"
  }
}
```

### Funnel Extraction

- **Dashboard**: Funnels > New Funnel > add events > set time window (max 30 days on most plans)
- Export funnel chart as CSV from the UI

### Typical Mobile App Events

`App Launched`, `Screen Viewed`, `Product Viewed`, `Added to Cart`, `Checkout Initiated`, `Purchase Completed`, `Notification Received`, `Notification Clicked`, `Signup Completed`

### Gotchas

- Event names and property names are **case-sensitive** and cannot be renamed after first ingestion.
- Free tier limits to **100K MAU**.
- Funnel analysis window capped at **30 days** on lower plans.
- Identity resolution uses **email, phone, or CleverTap ID**. Does not support anonymous-to-known merging as cleanly as Mixpanel/Amplitude.

---

## MoEngage

Similar positioning to CleverTap. Strong in push notification analytics and journey orchestration. Widely used in India-based consumer apps.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **Dashboard** | Analytics > Events > Export |
| **Data Export API** | `POST /v1/report/event/export` with date range. Returns download link for CSV/JSON. |
| **Cloud Storage Export** | Configure S3/GCS export in Data Settings |

### Event Schema

```json
{
  "event_name": "screen_viewed",
  "event_time": "2024-01-15T10:30:00Z",
  "user_id": "u_12345",
  "attributes": {
    "screen_name": "HomeScreen",
    "referrer": "push_notification"
  },
  "platform": "android"
}
```

### Funnel Extraction

- **Dashboard**: Analytics > Funnels > New > define steps > set conversion window
- Supports breakdown by user attributes and campaign source

### Typical Mobile App Events

`Session Started`, `Screen Viewed`, `Button Clicked`, `Sign Up`, `Login`, `Item Viewed`, `Added to Cart`, `Order Placed`, `Push Received`, `Push Clicked`

### Gotchas

- Event data export may have a **24-48 hour delay** depending on plan.
- Property names are flattened in exports; nested objects are dot-notation strings.
- Attribution data for campaigns is mixed into event properties, which can bloat the schema.

---

## PostHog (Open Source)

Self-hostable analytics with event tracking, session replay, feature flags, and experimentation. Rapidly growing in developer-focused teams.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **UI** | Events > filter > Export to CSV |
| **API** | `GET /api/projects/:id/events` with filters. Returns paginated JSON. |
| **ClickHouse (self-hosted)** | Query the `events` table directly via SQL |
| **Data Pipelines (Cloud)** | Export to S3, BigQuery, Snowflake via batch exports |

### Event Schema

```json
{
  "event": "$screen",
  "distinct_id": "user_abc",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "properties": {
    "$screen_name": "SettingsScreen",
    "$device_type": "Mobile",
    "$os": "Android",
    "$app_version": "3.2.1",
    "custom_prop": "value"
  }
}
```

System properties use `$` prefix. Custom properties are flat.

### Funnel Extraction

- **UI**: Insights > New > Funnel > add steps > configure conversion window and exclusion steps
- Funnels support **strict ordering**, **any ordering**, and **time-to-convert** views
- **API**: Use the Insights API to create/query funnel insights programmatically

### Typical Mobile App Events

`$screen`, `$autocapture`, `button_clicked`, `signup`, `login`, `item_viewed`, `add_to_cart`, `purchase`, `error`, `feature_flag_called`

### Gotchas

- Self-hosted PostHog uses **ClickHouse**. Queries on large datasets need proper date filters or they will be slow.
- `$autocapture` events capture everything by default and can generate enormous volume.
- Cloud and self-hosted schemas are slightly different in timestamp handling and property naming.
- Session replay is a separate feature from event analytics; session IDs link the two.

---

## Heap (Auto-Capture)

Heap captures **all user interactions automatically** (clicks, pageviews, form submissions, screen changes). No manual instrumentation needed for basic tracking.

### Exporting Event Data

| Method | Steps |
|--------|-------|
| **UI** | Any chart > Export CSV |
| **Connect (SQL)** | Heap mirrors data to Redshift, BigQuery, or Snowflake. Query directly. |
| **API** | Limited to user-level data (`/users` endpoint). No bulk event export API. |

### Event Schema (Warehouse)

Heap's warehouse schema uses separate tables:

| Table | Contents |
|-------|----------|
| `sessions` | Session start/end, device, geo |
| `pageviews` / `screen_views` | Automatic page/screen tracking |
| `all_events` | Every auto-captured interaction |
| `defined_events` | Events you've named/tagged in the UI |
| `users` | User properties and identity |

Events in the `all_events` table have fields like `event_id`, `session_id`, `user_id`, `time`, `type` (click/change/submit/pageview), `target_text`, `hierarchy` (CSS selector path).

### Funnel Extraction

- **UI**: Chart > Funnel > add steps using defined events or auto-captured elements
- Heap lets you **retroactively define events** and funnels since all interactions are already captured

### Gotchas

- Auto-capture generates **very high event volume**. Distinguishing signal from noise requires careful event definition.
- **No event names by default.** You define "virtual events" by pointing at captured interactions (e.g., "a click on the element matching `.checkout-btn`").
- Heap's mobile SDK auto-capture is less comprehensive than web; some manual tracking may still be needed.
- Warehouse sync may lag by **1-4 hours**.

---

## Session Replay Tools: Hotjar / FullStory / LogRocket

These are **session replay and heatmap tools**, not event analytics platforms. They record user sessions visually. They complement event analytics but do not replace it.

### What They Provide

| Capability | Hotjar | FullStory | LogRocket |
|------------|--------|-----------|-----------|
| Session replay | Yes | Yes | Yes |
| Heatmaps | Yes | Yes (click maps) | Limited |
| Rage click detection | Yes (via surveys) | Yes | Yes |
| Custom events | Limited | Yes (via API) | Yes (via API) |
| Funnel analysis | No | Yes (basic) | Yes (basic) |
| Error tracking | No | No | Yes (JS errors, network) |
| Event export | No | API only | API only |

### How to Extract Useful Data for UX Validation

1. **Rage clicks / dead clicks**: FullStory and LogRocket surface these automatically. Export as event counts or provide screenshots.
2. **Session segments**: Filter sessions by frustration signals, specific pages, or user attributes. Share session count + average duration.
3. **Heatmaps**: Screenshot the heatmap for the relevant screen. Provides visual evidence of where users tap/click.
4. **Error rates**: LogRocket captures frontend errors with session context. Export error list or screenshot.

### Gotchas

- **Privacy**: Session replay tools record DOM/screen state. PII masking must be configured or recordings may contain sensitive data.
- **Sampling**: Hotjar free plan captures only a percentage of sessions. Data may not be statistically representative.
- **Mobile support**: Hotjar is web-only. FullStory and LogRocket have mobile SDKs but with reduced fidelity compared to web.
- **No raw event export** from Hotjar. FullStory and LogRocket offer APIs but they are oriented toward session retrieval, not bulk event export.

---

## Common Event Naming Conventions

Consistent naming across platforms makes cross-platform analysis possible and reduces ambiguity during UX validation.

### Recommended Format

Use **snake_case** with the pattern: `object_action`

| Pattern | Examples |
|---------|----------|
| `screen_view` | `screen_view` (with `screen_name` param) |
| `object_action` | `button_tap`, `card_swipe`, `form_submit`, `modal_dismiss` |
| `flow_milestone` | `onboarding_start`, `onboarding_complete`, `checkout_start`, `checkout_complete` |
| `outcome` | `purchase_success`, `purchase_fail`, `signup_success`, `signup_fail` |
| `system` | `session_start`, `session_end`, `app_background`, `app_foreground`, `error` |

### Rules

- **Always snake_case.** Never camelCase, PascalCase, or spaces (some platforms silently transform casing).
- **Prefix with object, suffix with action.** `cart_add` not `add_to_cart`. Keeps events sortable/groupable.
- **Use consistent verbs.** Pick one of `tap`/`click`/`press` and stick with it across the entire app.
- **Parameterize, don't proliferate.** Use `button_tap` with a `button_name` property, not `button_tap_login`, `button_tap_signup`, etc.
- **Include `screen_name` on every event** as a property. Essential for UX validation per-screen.

---

## Minimum Event Set for UX Validation

To validate a UX review, the following events (or equivalent) must be present in the analytics data. Without these, validation is partial at best.

| Event | Purpose | Required Properties |
|-------|---------|-------------------|
| `session_start` | Establishes session boundaries | `session_id`, `device`, `os`, `app_version` |
| `session_end` | Session duration, clean vs abandoned exits | `session_id`, `duration_sec` |
| `screen_view` | Navigation flow, screen-level metrics | `screen_name`, `previous_screen` (optional but valuable) |
| `button_tap` | Core interaction tracking | `button_name`, `screen_name` |
| `funnel_start` | Entry into a key flow (onboarding, checkout, etc.) | `funnel_name`, `screen_name` |
| `funnel_complete` | Successful completion of a key flow | `funnel_name`, `screen_name`, `duration_sec` |
| `error` | Errors surfaced to the user | `error_type`, `error_message`, `screen_name` |

### What Each Enables

- **session_start + session_end**: Session duration analysis, bounce detection, session frequency.
- **screen_view**: Screen flow reconstruction, drop-off identification, navigation pattern analysis.
- **button_tap**: Validates whether users interact with the elements a UX review flags as important. Detects dead zones.
- **funnel_start + funnel_complete**: Conversion rate calculation, drop-off step identification, time-to-complete analysis.
- **error**: Correlates UX friction with technical failures. Identifies screens with high error rates.

### When Events Are Missing

If the provided data lacks any of these events, the skill should:

1. State which events are missing and what analysis is blocked.
2. Proceed with available data, clearly marking conclusions as **partial**.
3. Recommend the team instrument the missing events and provide a suggested schema.

---

## How to Provide Event Data to This Skill

The skill accepts analytics data in any of the following formats. Richer formats enable deeper analysis.

### Accepted Formats

| Format | Richness | Notes |
|--------|----------|-------|
| **CSV file** | High | One row per event. Must include `event_name`, `timestamp`, `user_id` or `session_id` at minimum. Include all properties as columns. |
| **JSON / JSONL** | High | Array of event objects or one event per line. Any of the platform schemas above are accepted as-is. |
| **BigQuery / SQL export** | Highest | Paste query results or export as CSV/JSON. Firebase BigQuery exports are directly supported. |
| **Dashboard screenshot** | Low | Screenshot of a funnel, chart, or event list from any platform. The skill will extract visible numbers but cannot drill deeper. |
| **Plain text event list** | Lowest | A list of event names with optional counts. Useful for confirming instrumentation coverage, not for deep analysis. |

### Providing Context Alongside Data

Always include when possible:

- **Platform name** (so the skill can interpret schema correctly)
- **Date range** of the data
- **Which screens/flows** the data covers
- **User segment** (all users, new users, specific cohort, specific geography)
- **App version(s)** included in the data

### Example: Minimal CSV

```csv
event_name,timestamp,user_id,screen_name,button_name,funnel_name,error_type
session_start,2024-01-15T10:00:00Z,u_001,,,
screen_view,2024-01-15T10:00:01Z,u_001,HomeScreen,,
button_tap,2024-01-15T10:00:05Z,u_001,HomeScreen,search_icon,
screen_view,2024-01-15T10:00:06Z,u_001,SearchScreen,,
funnel_start,2024-01-15T10:00:06Z,u_001,SearchScreen,,search_flow,
error,2024-01-15T10:00:10Z,u_001,SearchScreen,,,network_timeout
session_end,2024-01-15T10:02:00Z,u_001,SearchScreen,,
```

### Example: Dashboard Screenshot Submission

When providing a screenshot, include a note like:

> "This is a Mixpanel funnel for the checkout flow, Jan 1-15 2024, all users, iOS only. Steps: Cart Viewed > Checkout Started > Payment Entered > Order Completed."

This context lets the skill interpret the visual data accurately even without raw numbers.
