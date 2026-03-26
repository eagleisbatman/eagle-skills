# Eagle Skills

Custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool. Each skill extends Claude with domain-specific expertise, structured workflows, and production-quality deliverables.

This repo contains three skills that work together as a complete product evaluation pipeline:

1. **Eagle UX Review** — looks at your screens and tells you what's broken and why
2. **Eagle Product Diagnostics** — takes your real data and proves whether those problems actually cost you users and revenue
3. **Eagle Ad Review** — audits your ad creatives against marketing strategy, platform specs, and creative effectiveness research

Use them independently or combine them: review your product, validate with data, then audit the ads that drive users to it.

---

## Table of Contents

- [Eagle UX Review](#eagle-ux-review)
- [Eagle Product Diagnostics](#eagle-product-diagnostics)
- [Eagle Ad Review](#eagle-ad-review)
- [The Three-Skill Pipeline](#the-three-skill-pipeline)
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Built With](#built-with)
- [Contributing](#contributing)
- [License](#license)

---

# Eagle UX Review

**Expert-level UX audits grounded in 65+ UX laws and principles across 12 categories.**

Most UX feedback is vague: "the onboarding feels clunky," "the colors seem off," "maybe simplify it?" This skill produces the opposite — structured, evidence-based findings where every issue is tied to a specific UX law, a specific screen, a specific element, and a specific impact on the metric you care about most.

Point Claude at a screen recording, a set of screenshots, or a PRD, and receive a complete HTML report: severity-rated findings with embedded evidence, visual before/after design mockups built in CSS, a priority matrix ranked by business impact, and three-level recommendations (quick fix, proper fix, ideal state) for every issue found.

The review is deliberately brutal. Its value comes from surfacing problems the team may not want to hear — not from validating existing decisions.

**What you provide:** North star metric, target user profile, 2-3 reference apps, app identity — plus optional PRD, personas, analytics data, and competitive screenshots.

**What you get:** A self-contained HTML report with central thesis, severity-rated findings (each with evidence screenshots, UX law citations, north star impact, and fix recommendations), priority matrix, visual design mockups, time-to-first-value analysis, and UX laws summary.

**How it works:** 5-phase process — context gathering, frame extraction (1fps from video), systematic analysis against 65+ UX laws (6 per-screen checks + 6 per-flow checks), HTML report generation, and quality verification.

[Read the full methodology →](docs/ux-review-methodology.md)

---

# Eagle Product Diagnostics

**Data-validated product analysis using three-layer triangulation: design intent, instrumented behavior, and outcome truth.**

A UX review tells you: "This screen probably causes drop-off because the primary action is buried." But *probably* isn't proof. Product Diagnostics takes your actual data — analytics events and database outcomes — and validates each UX finding against reality. The result is not "we think this is broken" but "this IS broken, here's the funnel that proves it, and here's how much it costs."

**What you provide:** Goal definitions (success metrics per feature), event taxonomy (analytics events mapped to screens + funnels), and database outcomes (actual vs. target metrics). Optionally, a UX review report for per-finding validation.

**What you get:** An HTML report with goal scorecard (PASS/FAIL/PARTIAL per layer), funnel visualizations with drop-off analysis, per-feature three-layer diagnosis, disagreement analysis, business impact estimates, and prioritized actions.

**How it works:** The skill triangulates three independent evidence sources — design intent (UX review predictions), instrumented behavior (analytics events), and outcome truth (database metrics). Eight verdict patterns diagnose whether issues are UX problems, measurement gaps, value proposition failures, or something else entirely.

[Read the full methodology →](docs/product-diagnostics-methodology.md)

---

# Eagle Ad Review

**Strategy-first advertising creative review grounded in Meta ABCD, Kantar, System1, and Nielsen frameworks. Works across any medium.**

Most ad feedback is subjective: "I don't like the colors," "make the logo bigger," "this doesn't feel right." This skill produces the opposite — a structured evaluation where every creative is scored against the marketing strategy it's supposed to serve, the medium it runs in, and the research on what actually drives ad performance.

Point Claude at a folder of ad files — images, videos, audio, PDFs, scripts — across **any advertising medium**: social, display, video, radio, podcast, billboard, transit, print, TV, or experiential. Provide your campaign context and receive a complete HTML report.

The review evaluates creatives against their **marketing job**, not just visual aesthetics. An ugly ad that stops the scroll and converts is better than a beautiful ad nobody notices. A simple billboard that communicates in 3 seconds beats an elaborate one nobody can read at 60mph.

**What you provide:** Campaign strategy (objective, funnel stage, audience, medium/channels, KPI), brand context (value proposition, positioning, competitive landscape), and the creative files themselves.

**What you get:** An HTML report with 10-dimension scoring (weighted by campaign type and medium), per-market breakdowns, best/worst performer galleries, cross-cutting findings with evidence, platform compliance audit, creative system assessment, and a creative brief for the next production round.

**How it works:** Strategy-first 4-step process — gather marketing context, catalog and process all creative files, three-level analysis (strategic fit → execution quality → creative system health), then score and compile the report. Weights adjust dynamically by campaign type (awareness, DR, brand, multi-market) and medium (digital, radio, OOH, print, TV).

[Read the full methodology →](docs/ad-review-methodology.md)

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
- Together, you validate the entire user journey: ads bring users in, the product retains them, the data proves it works.

---

## Installation

### Quick install (recommended)

Interactive installer — choose which skills to install:

```bash
npx eagle-skills install
```

Or without npm:

```bash
curl -fsSL https://raw.githubusercontent.com/eagleisbatman/eagle-skills/main/install.sh | bash
```

The installer clones the repo to `~/.eagle-skills` and symlinks your selected skills into `~/.claude/skills/`. Symlinked skills update in place when you run `eagle-skills update`.

### Managing your installation

```bash
npx eagle-skills update      # Pull latest changes
npx eagle-skills status      # Show installed skills, check for updates
npx eagle-skills uninstall   # Remove skills and optionally the repo
```

### Manual install

If you prefer to manage it yourself:

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
ln -sf "$(pwd)/eagle-product-diagnostics" ~/.claude/skills/eagle-product-diagnostics
ln -sf "$(pwd)/eagle-ad-review" ~/.claude/skills/eagle-ad-review
```

Update with `git pull`. Symlinks mean installed skills update automatically.

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
UX audit — I'll provide a PRD and video walkthrough
```

**Product Diagnostics:**
```
validate these UX findings against our Firebase events
```
```
why isn't our retention metric moving? here's the event data and DB export
```

**Ad Review:**
```
review these ad creatives — here's the folder
```
```
critique our radio spots and billboard designs
```

Skills activate automatically when Claude detects matching intent.

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
- **Real-world case studies** — anonymized examples showing the pipeline in action

To contribute:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test by installing the skill locally and running a review
5. Submit a pull request with a clear description of what changed and why

---

## License

MIT
