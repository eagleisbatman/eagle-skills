---
name: eagle-ad-review
description: "This skill should be used when the user asks to review ad creatives, audit advertising campaigns, evaluate marketing collateral, critique ad designs, or assess creative performance across any medium. Trigger phrases include: 'review these ads', 'ad creative review', 'audit my ads', 'critique these creatives', 'what's wrong with my ads', 'ad review', 'creative review', 'evaluate these campaigns', 'review my marketing materials', 'ad teardown', 'creative audit', 'are these ads effective', 'review this radio ad', 'critique our billboard', 'evaluate our TV commercial', 'review this jingle', 'audit our print ads', 'review our podcast ad'. Also trigger when the user provides ad files (images, videos, audio, PDFs, scripts) and asks for feedback, or mentions ad platforms or channels (Meta, Google, TikTok, radio, OOH, print, TV, podcast, etc.) in the context of evaluating creative quality. This skill handles digital ads, audio ads (radio, podcast, jingles), out-of-home (billboards, transit), print (newspaper, magazine, flyers), television commercials, and any other advertising format."
---

# Eagle Ad Review

## Overview

Strategy-first advertising creative review grounded in established frameworks (Meta ABCD, Kantar Creative Effectiveness, System1, Nielsen) and medium-specific best practices. Evaluates ad creatives across **any medium** — digital (social, display, video), audio (radio, podcast, jingles), out-of-home (billboards, transit, DOOH), print (newspaper, magazine, flyers, direct mail), television, and experiential — not just for production quality, but for whether they do their marketing job.

The review is **brutal and honest**. Creative is the single largest driver of ad performance (47% of sales lift per Nielsen), so honest feedback here has direct ROI impact.

Output is always an **HTML report** with embedded thumbnails/transcripts, per-creative scoring, cross-cutting analysis, and prioritized recommendations. The report template is at `assets/report-template.html`.

## Process

### Phase 1: Gather Strategic Context

Before looking at a single creative, collect the marketing strategy. Present all questions in one message — the answers fundamentally change what "good" looks like.

**Required — Campaign Strategy:**
- **Campaign Objective** — What is this campaign optimizing for? (Awareness / App installs / Conversions / Retargeting / Re-engagement / Lead generation / Brand building). An awareness ad and a conversion ad have completely different success criteria.
- **Funnel Stage** — Where do these ads sit? Top-of-funnel (cold audience, first exposure), mid-funnel (consideration, familiar with brand), or bottom-funnel (retargeting, ready to act)?
- **Target Audience** — Demographics, psychographics, media habits, pain points. Tech literacy and device context if relevant. Per-market if multi-market campaign.
- **Medium & Channels** — What advertising formats and channels? This fundamentally shapes the evaluation:
  - **Digital**: Social (Meta Feed/Stories/Reels, TikTok, LinkedIn, X, Pinterest), Display (GDN, programmatic), Video (YouTube, OTT/CTV), Search (text ads)
  - **Audio**: Radio spots, podcast ads, streaming audio (Spotify), jingles/sonic branding
  - **Out-of-Home (OOH)**: Billboards, transit (bus/metro/taxi wraps), street furniture, digital OOH (DOOH), kiosks
  - **Print**: Newspaper, magazine, flyers/brochures, direct mail, point-of-sale
  - **Television**: TV commercials (15s/30s/60s), connected TV (CTV), infomercials
  - **Experiential**: Event booths, pop-ups, ambient/guerrilla
- **Primary KPI** — What metric defines success? (CTR, CPA, ROAS, install rate, video completion rate, brand lift, recall, footfall, coupon redemption). The KPI determines which creative elements matter most.
- **Output Format** — How should the report be delivered?
  - **HTML** (default) — Self-contained HTML file with embedded thumbnails and CSS. Best for interactive viewing.
  - **Word (.docx)** — Professional Word document using the Eagle Clean Doc design system. Best for sharing with stakeholders and clients.
  - **Both** — Generate both HTML and Word formats.
  - If the user doesn't specify, default to HTML. If they say "doc", "word", "docx", or "shareable", use Word. If they say "both", generate both.

**Required — Brand & Product:**
- **Product/Service** — What is being advertised? One sentence.
- **Value Proposition** — What is the single most compelling reason someone should care?
- **Brand Positioning** — How should the brand be perceived? (Affordable, premium, trustworthy, innovative, friendly, expert?)
- **Competitive Landscape** — Who is competing for the same audience's attention? What do their ads look like?

**Extended Inputs (ask for these — they transform the review):**
- **Performance Data** — CTR, CPA, ROAS, install rate by creative. If available, this lets the review correlate creative choices with actual results.
- **Brand Guidelines** — Logo usage rules, color palette, typography, tone of voice. Enables brand consistency scoring.
- **Creative Testing History** — What hooks/angles/formats have worked before? What's been tried and failed?
- **Budget & Resources** — Affects recommendation feasibility. Don't recommend $50K shoots for a $500/month budget.
- **Creative Testing Framework** — Is the team doing structured hook/body/CTA testing, or producing ad-hoc batches?
- **Fatigue Indicators** — Current ad frequency, how long creatives have been running, performance trend direction.

If the user provides a folder and says "just review these," make reasonable inferences and **explicitly flag every assumption** so they can correct.

### Phase 2: Process Input

#### Catalog Ad Files

Use `scripts/catalog-ads.sh` or manually scan the folder:

```bash
# Scan and catalog all ad files (images, videos, audio, PDFs)
bash scripts/catalog-ads.sh /path/to/ads/folder

# Output: file inventory grouped by type, dimensions, aspect ratio
```

**For image ads (digital, print, OOH):** View every image. Group by:
- Market/language (from folder structure or visual inspection)
- Aspect ratio / format (square, portrait 9:16, landscape 16:9, billboard ratios)
- Creative concept / angle (group similar-looking variations)
- Campaign vintage (if dateable from folder names or content)
- Medium (social, display, print, OOH — affects evaluation criteria)

**For video ads (digital, TV):** Extract key frames and view:
```bash
# Extract first frame, middle frame, and last frame (hook, body, CTA)
ffmpeg -i VIDEO -vf "select=eq(n\,0)+eq(n\,floor(total/2))+eq(n\,total-1)" -vsync vfq -q:v 2 thumb_%02d.jpg

# For longer videos, extract at 2-second intervals
mkdir -p ./ad-frames && ffmpeg -y -i VIDEO -vf "fps=1/2" -q:v 2 ./ad-frames/frame_%03d.jpg
```

**For audio ads (radio, podcast, jingle):**
- Listen to the full audio file
- Note: duration, voice talent quality, script structure (hook → body → CTA → tag)
- Check: sonic branding (jingle, sound logo), memorability, clarity at single listen
- If script/transcript is provided instead of audio, evaluate the written script

**For print/OOH materials (PDFs, high-res images):**
- View at intended scale context (billboard = viewed at 200+ feet, magazine = handheld)
- Check readability at viewing distance — fewer than 7 words for billboards
- Evaluate physical production considerations (CMYK color, bleed margins, paper stock if known)

**For all formats:** Build a creative inventory map:
```
Market/Region → Medium  → Format → Concept → Variations
  Brazil      → Social  → Square → Product Demo  → 3 variations
              → Social  → 9:16  → Value Prop     → 2 variations
  Kenya       → Social  → Square → Testimonial   → 4 variations
              → Radio   → 30s   → Problem-Hook   → 2 variations
              → OOH     → Billboard → Brand       → 1 variation
  National    → TV      → 30s   → Brand Story    → 1 variation
              → Print   → A4    → Product Launch  → 3 variations
```

### Phase 3: Analyze

**Read `references/methodology.md` before this step.** It contains the full 10-dimension scoring framework, rubrics, and anti-pattern catalog.

**Read `references/ad-platforms.md`** for platform-specific specs, safe zones, and creative guidelines.

**Three-Level Analysis:**

**Level 1 — Strategic Fit (most important)**
Does each creative do the job the campaign needs?
- Does the hook earn attention in the first 1-3 seconds / first visual impression?
- Does the message match the funnel stage? (Education for cold, urgency for warm)
- Is the value proposition clear within 5 seconds?
- Does the CTA match the campaign objective?
- Is the creative-to-landing-page promise consistent?

**Level 2 — Execution Quality**
Is the creative well-made?
- Brand presence: logo visible, brand colors used, distinctive assets present?
- Visual hierarchy: clear focal point, readable text, CTA prominence?
- Platform compliance: correct aspect ratio, safe zones respected, text overlay limits?
- Production quality: resolution, composition, lighting, authentic vs. AI-generated?
- Localization quality: proper translation, cultural appropriateness, no mixed languages?

**Level 3 — Creative System Health**
Does the creative set work as a testing/scaling system?
- Is there a structured testing framework (hook/body/CTA variations)?
- Is there meaningful variation across creatives, or are they near-duplicates?
- Is brand consistency maintained across markets and formats?
- Is there creative for each funnel stage, or only one stage?
- Are there signs of creative fatigue (same concepts recycled)?

### Phase 4: Generate Report

Generate the report in the user's chosen format (HTML, Word, or both). Default to HTML if not specified.

#### HTML Output

Use the structure from `assets/report-template.html`. Copy representative ad thumbnails to a `thumbnails/` directory alongside the HTML file.

**Required Report Sections:**

1. **Cover** — Campaign/brand name, context cards (objective, audience, platforms, KPI, markets, creative count)
2. **Overall Verdict** — Score out of 10 with 1-2 sentence thesis. Dark box.
3. **Creative Inventory** — What was reviewed: counts by market, format, concept, medium
4. **Scoring Dashboard** — 10-dimension radar chart scores with overall weighted score
5. **Best & Worst Performers** — Gallery of top 3 and bottom 3 creatives with explanations
6. **Per-Market / Per-Campaign Breakdown** — Score and key findings per market or campaign group
7. **Cross-Cutting Findings** — Issues that appear across the entire creative set (ordered by impact)
   - Each finding: evidence thumbnails, what's wrong, why it matters for the KPI, recommendation
8. **Platform Compliance Audit** — Pass/fail per creative against platform specs
9. **Creative System Assessment** — Testing framework evaluation, variation analysis, fatigue risk
10. **Recommended Actions** — Prioritized by expected KPI impact. Three levels: quick fix, next sprint, strategic shift.
11. **Creative Brief for Next Round** — Based on findings, what should the next batch of creatives focus on?

#### Word Output (.docx)

When the user requests Word format, generate a `.docx` file using the Eagle Clean Doc design system. **Read `../eagle-clean-doc/SKILL.md` and `../eagle-clean-doc/references/design-system.md`** for the complete design system.

The Word report contains the same sections as the HTML report, adapted for Word:
- **Cover page** → Title (H1) + context table (campaign, audience, platforms, KPI, creative count)
- **Overall Verdict** → Bold paragraph with score and thesis, gray background shading
- **Creative Inventory** → Clean Doc table (market × medium × format × concept)
- **Scoring Dashboard** → Table with 10 dimension scores and weighted overall (no radar chart — list the scores instead)
- **Best/Worst Performers** → Sections with inline thumbnail images and explanations
- **Per-creative breakdowns** → Tables with scores per dimension
- **Platform Compliance** → Table with pass/fail per creative per spec
- **Creative Brief** → Structured paragraphs with H2/H3 hierarchy

Save as `ad-review-report.docx` alongside the HTML (if both formats requested).

### Phase 5: Writing Principles

- **Strategy over aesthetics.** An ugly ad that converts beats a beautiful ad that doesn't. Always evaluate against the marketing objective first.
- **Show the math.** "This ad has weak brand presence" is vague. "Brand logo appears at 0:12 — 80% of viewers have already scrolled past by 0:03" connects to real behavior.
- **Compare to what works.** Reference winning ad patterns from the platform, category, or the brand's own history.
- **Be specific about what to change.** "Improve the hook" is useless. "Replace the logo animation opener with a problem-agitation statement in the first frame, set in 48px+ text within the Stories safe zone" is actionable.
- **Respect the budget.** Recommendations must be feasible within the team's resources. Flag when a structural problem requires investment vs. when it's a simple creative swap.
- **Quantify when possible.** If performance data is available, tie findings to actual numbers. If not, reference industry benchmarks.
- **Don't confuse personal taste with effectiveness.** The review is about what works for the target audience, not what looks good to the reviewer.

## Key Anti-Patterns

Check every review for these recurring issues:

1. **No Hook** — Ad opens with logo animation, slow pan, or generic imagery instead of earning attention in 1-3 seconds
2. **Message Overload** — Trying to communicate 3+ ideas in one creative. Best ads say one thing clearly.
3. **Format Mismatch** — Running landscape video in vertical placements (40% screen waste) or vice versa
4. **Ghost CTA** — No call-to-action, or CTA buried/invisible. Every ad needs a clear next step.
5. **Stock Photo Syndrome** — Generic stock imagery that could be for any brand. Authentic > polished.
6. **AI Uncanny Valley** — AI-generated people/scenes that feel synthetic and erode trust
7. **Translation, Not Transcreation** — Direct word-for-word translation that loses cultural meaning, humor, or emotional tone
8. **Identical Twins** — 10 "variations" that are the same layout with different photos. No meaningful testing surface.
9. **Funnel Blindness** — Same creative for cold and warm audiences. Different funnel stages need different creative jobs.
10. **Brand Amnesia** — No consistent visual identity across the set. Different typography, colors, logo treatments across markets.
11. **Silent Video** — Video with important audio content but no captions/text overlays (85% watch on mute)
12. **Safe Zone Violations** — Text/CTA placed in platform UI overlay zones where it gets obscured

## Resources

### Reference Files
- **`references/methodology.md`** — Full 10-dimension scoring framework with rubrics, creative effectiveness research, anti-pattern catalog, scoring calculations, and industry benchmarks. Includes format-specific dimension adjustments.
- **`references/ad-platforms.md`** — Digital platform specs (Meta, Google, TikTok, LinkedIn, X, Pinterest). Aspect ratios, safe zones, text limits, video length guidelines.
- **`references/ad-formats.md`** — Non-digital format guidelines: radio/audio (structure, duration, production), OOH/billboards (viewing distance, readability, size specs), print (bleed, CMYK, typography), TV (storytelling arc, production values, regulatory), experiential, and format-specific evaluation criteria.

### Assets
- **`assets/report-template.html`** — HTML/CSS template for the ad review report. Brutalist styling matching eagle-ux-review aesthetic.

### Scripts
- **`scripts/catalog-ads.sh`** — Scans an ad folder, catalogs all files by type/dimensions/aspect ratio, groups by directory structure, and outputs a structured inventory. Usage: `catalog-ads.sh <folder_path> [output_dir]`

## Notes

- This skill evaluates creative effectiveness, not media buying strategy. It doesn't review targeting, bidding, or budget allocation.
- **Multi-format campaigns** should be evaluated per-medium AND for cross-medium consistency (does the radio ad reinforce the same message as the social ad?).
- **Audio ads** without audio files can still be reviewed via scripts/transcripts — evaluate script structure, messaging, and CTA clarity.
- **OOH/Billboard** evaluation focuses on the "3-second rule" — if the message isn't clear in 3 seconds at driving speed, it fails.
- **TV commercials** get the deepest analysis — storytelling arc, production values, brand reveal timing, emotional build, and format compliance (15s/30s/60s structure).
- Multi-market campaigns should be evaluated both per-market AND for cross-market consistency.
- If performance data is available, always correlate creative observations with actual metrics. The data wins.
- For brands with formal brand guidelines, evaluate adherence. For brands without, flag the absence as a structural issue.
