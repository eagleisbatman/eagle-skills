---
name: eagle-ux-review
description: "This skill should be used when the user asks to conduct a UX review, UX audit, usability review, heuristic evaluation, or design critique of any digital product. Trigger phrases include: 'review this app', 'UX audit', 'UX review', 'critique this design', 'what's wrong with this UI', 'analyze this screen', 'teardown this app', 'heuristic evaluation', 'usability review', 'evaluate the UX', 'design feedback', 'UX teardown'. Also trigger when the user uploads screenshots or video of an app and asks for feedback, or mentions UX laws (Hick's Law, Fitts's Law, Jakob's Law, etc.) in the context of evaluating a product. This skill handles video files (extracting frames via ffmpeg at 1-second intervals), screenshot sets, single screen images, or PRD-based flow validation. Always use this skill for any UX evaluation task even if the user doesn't explicitly say 'UX review'."
---

# Eagle UX Review

## Overview

Expert-level UX reviews grounded in 65+ established UX laws and principles across 12 categories. Produces structured, severity-rated findings tied to a north star metric, with evidence from screenshots/video frames, actionable recommendations, and visual design mockups.

The review is **brutal and honest** — its value comes from surfacing problems the team may not want to hear, not from validating existing decisions.

Output is always an **HTML report** with embedded screenshots, current-vs-proposed mockups, and a priority matrix. The report template is at `assets/report-template.html`.

## Process

### Phase 1: Gather Context

Before analyzing screens, collect structured input. Present all questions in one message:

**Required Inputs:**
- **North Star Metric** — single metric defining success (conversion rate, D7 retention, revenue/user, task completion rate, DAU/MAU). Help the user pick one if they don't know.
- **Target User** — demographics, tech/reading literacy, device types, connectivity conditions, daily app habits
- **Reference Apps** — 2-3 apps the target user opens daily. These set the mental model. Infer if the user doesn't specify (e.g., gen Z social users → Instagram/TikTok; business professionals → Slack/LinkedIn; general consumers → WhatsApp/Amazon).
- **App Identity** — one-word category (chat, content, marketplace, tool, social, utility). Then verify: does the UI match?
- **Output Format** — How should the report be delivered?
  - **HTML** (default) — Self-contained HTML file with embedded screenshots and CSS. Best for interactive viewing.
  - **Word (.docx)** — Professional Word document using the Eagle Clean Doc design system. Best for sharing with stakeholders.
  - **Both** — Generate both HTML and Word formats.
  - If the user doesn't specify, default to HTML. If they say "doc", "word", "docx", or "shareable", use Word. If they say "both", generate both.

**Extended Inputs (ask for these — they dramatically improve review quality):**
- **PRD / Hypothesis Document** — product requirements, intended user flows, success criteria, feature specs. If provided, add a "PRD Validation" section to the report checking each hypothesis against observed reality.
- **User Personas** — detailed persona profiles beyond basic demographics. Scenarios, goals, pain points.
- **Analytics Data** — drop-off rates, session duration, funnel completion, screen-level metrics. Connects findings to real numbers.
- **Competitive Analysis** — screenshots or flows from competitor apps for direct comparison.
- **Known Pain Points** — what the team already suspects is broken.
- **Business Model** — how the app generates revenue. Affects which engagement patterns are ethical.
- **Technical Constraints** — platform limitations, API restrictions, offline requirements.
- **Intended Happy Path** — the ideal flow: install → onboard → home → core action → repeat.

If the user provides media and says "just review it," make reasonable inferences and **call out assumptions explicitly** so they can correct.

### Phase 2: Process Input

#### Video Files

Use `scripts/extract-frames.sh` or run directly:

```bash
# 1-second intervals (default — do not use 2-second)
mkdir -p ./ux-review-frames
ffmpeg -y -i VIDEO_PATH -vf "fps=1" -q:v 2 ./ux-review-frames/frame_%03d.jpg

# Get metadata
ffprobe -v quiet -print_format json -show_format -show_streams VIDEO_PATH
```

**Critical:** View **every single frame**. Do not sample or skip. Screen transitions, loading states, and hesitation points only surface from exhaustive frame review.

While viewing, note:
- Frame numbers where screens change (reconstruct timing)
- Loading/spinner durations (count frames × 1 second)
- What the user tapped (visual feedback, highlighted elements)
- What the user did NOT tap (available but ignored)
- Dwell time on each screen (hesitation = confusion signal)

#### Screenshots
- View each image
- Confirm flow order if ambiguous
- Ask about missing states (loading, error, empty)

#### After Processing
Construct a flow map:
```
Screen 1 (name) → Screen 2 (name) → Screen 3 (name)
  [Xs loading]     [Y choices]       [Z taps to reach]
```

### Phase 3: Analyze

**Read `references/ux-laws.md` before this step.** It contains 65+ laws organized by 12 categories with audit checklists, including Low-Literacy & Emerging Market Design principles and UX Metrics.

**Read `references/methodology.md`** for the full evaluation framework, severity rating system, and PRD validation process.

**Per-Screen Evaluation:**
1. Identity Match (Jakob's Law) — matches user's reference app expectations?
2. Action Clarity (Hick's + Fitts's) — how many choices? Primary action obvious/reachable?
3. Information Load (Miller's + Cognitive Load) — how much to process?
4. Visual Hierarchy (Von Restorff + Gestalt) — what stands out? Right thing?
5. Progress Signal (Goal Gradient + Zeigarnik) — user feels movement?
6. Response Time (Doherty) — feedback instant? Waits informative?

**Flow-Level Evaluation:**
1. Time-to-first-value — seconds/taps from open to first meaningful interaction
2. Decision accumulation — total choices across the flow
3. Behavioral mode — training active (ask/create) or passive (browse/read)?
4. Open loops — reasons to return?
5. Peak and end — emotional high point? How does flow end?

**If PRD Provided:**
Validate each PRD requirement/hypothesis against observed behavior. For each:
- Does the implementation match the spec?
- Does the user flow match the intended happy path?
- Are success criteria achievable given the UX?

### Phase 4: Generate Report

Generate the report in the user's chosen format (HTML, Word, or both). Default to HTML if not specified.

#### HTML Output

Use the structure from `assets/report-template.html`. Copy key frames to a `frames/` directory alongside the HTML file for relative image references.

**Required Report Sections:**

1. **Hero / Cover** — app name, context cards (north star, target user, reference apps, app identity, device/connectivity, PRD status)
2. **Central Thesis** — 1-2 sentences on the fundamental problem. Dark box.
3. **Executive Summary** — severity counts (4 stat cards), user journey flow map with frame thumbnails
4. **PRD Validation** (if PRD provided) — checklist of each hypothesis with pass/fail/warning status and evidence
5. **Detailed Findings** — ordered by severity × north star impact. Each finding includes:
   - Severity badge + title + UX law tags
   - Evidence (frame screenshot)
   - What happens (observed behavior)
   - Why it matters (UX law connection + north star impact)
   - Reference app comparison
   - Actionable recommendation
6. **Priority Matrix** — table: Priority | Issue | Fix | Severity | North Star Impact
7. **Visual Design Recommendations** — side-by-side current vs. proposed mockups built with HTML/CSS (phone-shaped containers showing UI changes)
8. **Time to First Value Analysis** — timeline showing each step with problem markers
9. **UX Laws Violated Summary** — table mapping laws to findings

#### Word Output (.docx)

When the user requests Word format, generate a `.docx` file using the Eagle Clean Doc design system. **Read `../eagle-clean-doc/SKILL.md` and `../eagle-clean-doc/references/design-system.md`** for the complete design system (Helvetica body, Courier New for code, monochrome palette, compact margins).

The Word report contains the same sections as the HTML report, adapted for Word:
- **Cover page** → Title (H1) + context table (north star, target user, reference apps, app identity)
- **Central Thesis** → Bold paragraph with gray background shading
- **Severity badges** → Bold parenthetical markers: **(CRITICAL)**, **(MAJOR)**, **(MINOR)**, **(INFO)**
- **Evidence screenshots** → Inline images using `ImageRun` (max width 10800 DXA = full content width, scale proportionally)
- **Priority matrix** → Clean Doc table styling (gray header, bordered cells)
- **Side-by-side mockups** → Sequential sections: "Current" heading + image, then "Proposed" heading + image
- **UX law tags** → Inline code spans in Courier New with gray background
- **Flow maps** → Code block styling (bordered paragraph, Courier New)

Save as `ux-review-report.docx` alongside `ux-review-report.html` (if both formats requested).

### Phase 5: Writing Principles

- **Be brutal.** Value comes from honesty, not diplomacy.
- **Every finding connects to the north star.** "This violates Hick's Law" is incomplete. Must explain how it suppresses the metric.
- **Be specific.** Reference exact screens, exact elements, exact timing.
- **Compare to reference apps.** "WhatsApp/Spotify/Amazon does X; this app does Y" beats vague advice like "the input should be at the bottom."
- **Offer fixes, not just diagnoses.** Every finding gets an actionable recommendation.
- **Present options for strategic decisions.** Don't prescribe when the team needs to choose.
- **Challenge the premise.** If the UI contradicts stated identity, that's the foundational issue.
- **Don't pad with praise.** Brief mention of what works. Depth on what's broken.

## Key Anti-Patterns

Check every review for these recurring issues:
1. **Identity Crisis** — name/description says one thing, UI says another (e.g., a "marketplace" that's actually a blog, a "tool" that's actually a content feed)
2. **Content/Feature Mismatch** — UI elements that contradict the app's stated identity (e.g., image cards and view counts in a chat app, social features in a utility, gamification in a professional tool)
3. **Mode Selection Gates** — forcing a mode choice before acting (e.g., photo/voice/text input selection, category picker before search, account type selection before signup)
4. **UX Theater** — screens that look functional but serve no purpose
5. **Response Overload** — AI or system generating walls of text/data instead of digestible, contextual responses
6. **Dead-End Interactions** — no suggestion chips, follow-up prompts, related items, or continuation signals after completing an action
7. **Invisible Primary Action** — the core interaction (input field, CTA, search bar) is hidden, buried, or not persistent
8. **Dead Screens** — loading states, spinners, transitions adding time without value
9. **No History/State** — every session starts fresh, no memory of past interactions or preferences
10. **Literacy Mismatch** — language complexity doesn't match the target user's reading level

## Resources

### Reference Files
- **`references/ux-laws.md`** — Complete catalog of 65+ UX laws organized by category with audit checklists. **Read before every review.**
- **`references/methodology.md`** — Full evaluation framework, severity system, PRD validation process, deliverable format specs.

### Assets
- **`assets/report-template.html`** — HTML/CSS template for the review report. Contains all required styles and section structure.

### Scripts
- **`scripts/extract-frames.sh`** — Frame extraction utility. Usage: `extract-frames.sh <video> [output_dir] [interval]`. Default 1-second intervals.

## Notes

- Default frame extraction interval is **1 second**, not 2. This captures transitions that 2-second intervals miss.
- Video input produces richer analysis than screenshots (timing, behavior, transitions).
- The skill assumes access to `ffmpeg` and `ffprobe` for video processing.
- For low-literacy audiences, always check: reading level, vocabulary complexity, sentence length, icon clarity, and reliance on text vs. visual cues.
- When a PRD is provided, the review becomes significantly more valuable — it validates whether the implementation matches the hypothesis, not just whether the UX is good in isolation.
