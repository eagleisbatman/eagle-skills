# UX Review Methodology

## Phase 1: Context Gathering

### Required Context
1. **North Star Metric** — single metric defining success (conversion rate, DAU, session length, D7 retention, revenue/user, task completion rate)
2. **Target User Profile** — demographics, tech literacy, device types, connectivity, daily app habits, reading level
3. **App Identity** — category (chat, content, marketplace, tool, social, utility). What does the user THINK they're downloading?
4. **Reference Apps** — 2-3 apps the target audience uses most. These define the mental model.

### Extended Context (High-Value Additions)
5. **PRD / Hypothesis Document** — product requirements, intended user flows, success criteria, feature specifications. Enables PRD Validation section.
6. **User Personas** — detailed profiles with scenarios, goals, pain points, tech comfort, motivations
7. **Analytics Data** — screen-level drop-off rates, session duration, funnel completion, feature usage rates. Grounds findings in real numbers.
8. **Competitive Analysis** — screenshots or flows from 2-3 competitor/reference apps for direct comparison
9. **Screen Flow / Happy Path** — intended journey: install → onboard → home → core action → repeat
10. **Known Pain Points** — what the team already suspects is broken
11. **Business Model** — how the app monetizes. Affects which engagement patterns to recommend.
12. **Technical Constraints** — platform requirements, API limitations, offline requirements, device targets
13. **Launch Stage** — MVP, beta, growth, mature. Affects severity calibration.

### PRD Validation Process

When a PRD is provided, extract:
- **User flow hypotheses** — "the user will go from A → B → C"
- **Success criteria** — "80% of users should complete onboarding in <60s"
- **Feature specifications** — "the input supports text, voice, and image"
- **Target metrics** — "D7 retention of 40%"

For each, create a validation entry:
- **Hypothesis**: What the PRD says should happen
- **Observed**: What actually happens in the video/screenshots
- **Status**: Pass / Fail / Partial / Not Testable
- **Evidence**: Specific frames/screenshots
- **Impact**: How the gap affects the north star metric

## Phase 2: Input Processing

### Video Processing
1. Extract frames at **1-second intervals**: `ffmpeg -i video.mp4 -vf "fps=1" -q:v 2 frames/frame_%03d.jpg`
2. Get metadata: `ffprobe -v quiet -print_format json -show_format -show_streams video.mp4`
3. View **every single frame** sequentially — do not skip or sample
4. Note timestamps of screen changes, loading states, user actions, hesitation points
5. Track: what did the user DO vs. what the app wanted them to do?

### Screenshot Processing
1. View each screenshot
2. Confirm flow order if ambiguous
3. Identify missing screens (transitions, loading, error, empty states)

### Observation Checklist During Processing
- [ ] Time spent on each screen (from timestamps)
- [ ] User hesitation points (where did they pause?)
- [ ] Path taken vs. optimal path
- [ ] Loading/waiting durations (count frames × interval)
- [ ] Screen real estate allocation (content vs. chrome vs. whitespace)
- [ ] Tap target sizes (estimate from phone bezels)
- [ ] Text readability (font sizes relative to screen)
- [ ] What the user tapped
- [ ] What the user did NOT tap (available but ignored)
- [ ] Any error states or confusion signals

## Phase 3: Analysis Framework

### Per-Screen Analysis (6-Point Check)

For EACH screen, evaluate:

| Check | Laws | Key Question |
|-------|------|-------------|
| Identity Match | Jakob's Law | Does this screen match reference app expectations? |
| Action Clarity | Hick's + Fitts's | How many choices? Primary action obvious/reachable? |
| Information Load | Miller's + Cognitive Load | How much must the user process/remember? |
| Visual Hierarchy | Von Restorff + Gestalt | What stands out? Is it the right thing? |
| Progress Signal | Goal Gradient + Zeigarnik | Does user feel movement toward goal? |
| Responsiveness | Doherty | Is feedback instant? Loading states informative? |

### Flow-Level Analysis (6-Point Check)

After all screens individually:

| Check | Method |
|-------|--------|
| Time-to-First-Value | Seconds/taps from app open → first meaningful interaction |
| Decision Accumulation | Total decisions across the flow (compound Hick's) |
| Emotional Curve | Map peak-end rule across the journey |
| Open Loops | Reasons to return? (Zeigarnik) |
| Identity Consistency | Every screen consistent with stated identity? |
| Behavioral Mode | Training active (ask/create) or passive (browse/read)? |

### Competitive Comparison

For each reference app:
1. How many taps to equivalent first action?
2. What layout patterns are shared/different?
3. Where does the reviewed app break expectations?
4. Side-by-side screen comparisons for key moments

### Low-Literacy Specific Checks

For apps targeting low-literacy users:
- [ ] Reading level of all UI text (target: 3rd-5th grade)
- [ ] Vocabulary complexity (no jargon, no technical terms)
- [ ] Sentence length (target: <10 words)
- [ ] Icon clarity (self-explanatory without labels?)
- [ ] Icon + label pairing (both present, not icon-only)
- [ ] Visual cues vs. text reliance
- [ ] Language options and discoverability
- [ ] Voice input availability and prominence
- [ ] Number literacy assumptions
- [ ] Cultural appropriateness of imagery/icons

## Phase 4: Output Structure

### Severity Ratings

| Level | Definition | North Star Impact | Action Required |
|-------|-----------|-------------------|-----------------|
| **Critical** | Directly suppresses the north star metric. Structural/architectural issue. | >20% estimated impact | Fix before next release |
| **High** | Significant experience degradation. Measurable drop-off likely. | 10-20% estimated impact | Fix in current sprint |
| **Medium** | Suboptimal but functional. Clear improvement opportunity. | 5-10% estimated impact | Fix in next quarter |
| **Low** | Polish item. Nice-to-have. | <5% estimated impact | Backlog |

**Rating factors** (consider all three per Nielsen):
1. **Frequency:** How often does the problem occur? (Common vs. rare)
2. **Impact:** How difficult is it for users to overcome? (Easy vs. impossible)
3. **Persistence:** Is it a one-time or repeated problem? (Users learn to work around it, or it bothers them every time)

### Prioritization: RICE + UX Severity

Combine RICE framework with UX severity to rank implementation order:

| Factor | Definition | Scoring |
|--------|-----------|---------|
| **Reach** | How many users encounter this issue? | % of users per time period |
| **Impact** | How much does it affect each user? | 3=massive, 2=high, 1=medium, 0.5=low |
| **Confidence** | How sure are you of the impact estimate? | 100%=high, 80%=medium, 50%=low |
| **Effort** | How much work to fix? | Person-weeks (lower = better) |

```
RICE Score = (Reach × Impact × Confidence) / Effort
```

### Business Impact Statement Template

For each critical/high finding, quantify business impact:

```
Finding: [Brief description]
Who is affected: [User segment + estimated % or count]
How often: [Every session / weekly / edge case]
What happens: [Abandons, contacts support, workaround]
Estimated impact: [Revenue/retention/support cost with calculation]
If fixed: [Expected improvement in metric + payback period]
```

### Competitive UX Benchmarking

When competitive analysis inputs are provided:

1. **Select 3-5 competitors** (direct + aspirational)
2. **Choose 5-10 comparable tasks** across products
3. **Create standardized rubric**: task completion, steps required, error handling, heuristic scores
4. **Execute parallel evaluations**: same evaluator, same tasks, same device
5. **Compile comparison matrix**: score each dimension per competitor
6. **Gap analysis**: where behind, where ahead, what competitors do that you don't

### HTML Report Structure

**The report must always be HTML.** Structure as follows:

#### Section 1: Hero / Cover
- App name as large heading
- Subtitle describing the review scope
- Context cards grid: North Star, Target User, Reference Apps, App Identity
- Additional cards if available: Device/Connectivity, PRD Status, Launch Stage
- Metadata line: date, video duration, resolution, location

#### Section 2: Central Thesis
- Dark background box
- 1-2 sentences: the fundamental, structural problem
- Supporting paragraph connecting thesis to north star

#### Section 3: Executive Summary
- Severity stat cards (4-column grid: Critical/High/Medium/Low counts)
- User journey flow map: horizontal scroll of frame thumbnails with labels and timing
- Key metric: time from app open to first meaningful value

#### Section 4: PRD Validation (if PRD provided)
- For each PRD hypothesis/requirement:
  - Status icon (pass/fail/warning)
  - Hypothesis statement
  - Observed behavior
  - Evidence (frame reference)
  - Gap analysis

#### Section 5: Detailed Findings
- Ordered by severity × north star impact (NOT chronological)
- Each finding:
  - Left-bordered card (color = severity)
  - Header: severity badge + title + UX law tags
  - Evidence row: frame screenshot (180px wide) + text column
  - "What Happens" — observed behavior
  - "Why This Matters" — UX law explanation + north star connection
  - Reference app comparison where applicable
  - Green recommendation box with actionable fix

#### Section 6: Priority Matrix
- Table: Priority # | Issue | Fix | Severity | North Star Impact
- Ordered by implementation priority

#### Section 7: Visual Design Recommendations
- Side-by-side mockups: Current (red border) vs. Proposed (green border)
- Phone-shaped containers with HTML/CSS mockup UI
- Key changes listed below each comparison
- Cover at minimum: home screen, primary interaction, key result/response screen

#### Section 8: Time to First Value Analysis
- Two timelines: Current (with problem markers) and Target
- Timeline items: timestamp, description, problem flag

#### Section 9: UX Laws Violated Summary
- Table: Law | Violation | Finding Reference

#### Section 10: Footer
- App name, date, methodology summary
- Frame count and extraction interval

### Writing Principles

1. **Lead with the most damaging finding**, not chronological order
2. **Every finding connects to north star** — "violates Hick's Law" is incomplete; must explain metric impact
3. **Be specific** — "CTA is 24x24pt, below 44pt minimum" not "button is small"
4. **Provide evidence** — reference specific frame number/screenshot
5. **Offer actionable fixes** — every finding gets a recommendation
6. **Compare to reference apps** — "[Reference app] does X; this app does Y" (e.g., "Spotify shows playback controls persistently; this app hides them")
7. **Present options for strategic decisions** — don't prescribe when the team needs to choose
8. **Challenge the premise** — if UI contradicts stated identity, flag it as foundational
9. **Don't pad with praise** — brief mention of wins, depth on problems
10. **Don't be biased by user claims** — if "onboarding is fine" but it's clearly broken, review it

### Frame Selection for Report

Select 10-15 key frames that tell the story:
- Play Store / first impression
- App launch / splash
- Onboarding / setup screens
- Home screen (fully loaded)
- Primary interaction screen
- Loading / waiting states
- Result / response / output screen
- Any error or confusion states
- Flow endpoints

Copy selected frames to a `frames/` directory alongside the HTML file. Reference with relative paths: `src="frames/frame_037.jpg"`.

### Three-Level Recommendations

For high-severity findings, provide three tiers:
1. **Quick fix** (can ship this week): Minimum change to reduce the pain
2. **Proper fix** (next sprint): Correct solution with design thinking
3. **Ideal state** (future): Best possible experience if unconstrained

This respects that teams have different timelines and resource levels.

### Implementation Roadmap

Structure recommendations by timeline:
- **Immediate (1-2 weeks):** Critical severity issues, quick wins
- **Short-term (1-3 months):** Major severity issues, flow improvements
- **Medium-term (3-6 months):** Structural changes, IA improvements
- **Long-term (6-12 months):** Strategic redesigns, platform changes

## Phase 5: Quality Checks

Before delivering the report:

- [ ] Every finding connects to north star metric
- [ ] Every finding has a severity rating
- [ ] Every finding references a specific UX law
- [ ] Every finding has evidence (frame/screenshot reference)
- [ ] Every finding has an actionable recommendation
- [ ] Priority matrix is ordered by implementation priority
- [ ] Visual mockups show at least home screen and primary interaction
- [ ] Time-to-first-value is calculated
- [ ] All referenced frames exist in the frames/ directory
- [ ] HTML renders correctly with frame images
- [ ] If PRD provided: every testable hypothesis is validated

### Low-Literacy Audience Additional Checks

- [ ] Cover-the-text test passed: screens understandable without reading
- [ ] Voice-only test: core task completable entirely by voice
- [ ] Reading level of all UI text at grade 3-5
- [ ] All icons paired with labels (not icon-only)
- [ ] Images are realistic/photographic, not abstract
- [ ] Linear flow with clear "next step" on every screen
- [ ] Reference app pattern alignment verified (e.g., WhatsApp, YouTube, or other daily apps)
- [ ] Error recovery possible in 1-2 taps
- [ ] Meaningful defaults set for all selections
- [ ] Local language and dialect supported
