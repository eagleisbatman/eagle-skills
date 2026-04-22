# Eagle Skills

Skills and agents for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool. Skills extend Claude with domain-specific expertise and structured workflows. Agents are autonomous reviewers that audit, fix, and re-review your code.

**7 skills** — invoked via slash commands:

1. **Eagle UX Review** — looks at your screens and tells you what's broken and why
2. **Eagle Product Diagnostics** — takes your real data and proves whether those problems actually cost you users and revenue
3. **Eagle Ad Review** — audits your ad creatives against marketing strategy, platform specs, and creative effectiveness research
4. **Eagle Anti-Slop** — detects and eliminates AI-generated slop in code, text, and design
5. **Eagle Clean Doc** — modern Word document generation with a clean, monochrome design system
6. **Eagle Clean Sheet** — modern Excel spreadsheet generation with consistent styling
7. **Eagle Multi-Stack Scaffolder** — research-driven project scaffolding for 13+ technology stacks

**14 agents** — dispatched by Claude's Agent tool:

| Agent | Category | What it does |
|-------|----------|-------------|
| **Eagle Spectral Suite** | orchestrator | Detects intent and tech stack, dispatches the right specialist agents |
| **Eagle Spectral Plan** | lifecycle | Scopes features, evaluates approaches, produces implementation plans |
| **Eagle Spectral Investigate** | lifecycle | Root-cause debugging — traces code paths, tests hypotheses, applies fixes |
| **Eagle Spectral Ship** | lifecycle | Pre-ship pipeline — runs gates, cleans diff, creates PR |
| **Eagle Triad Review** | review | Single-pass 3-lens review: security + ops/reliability + maintainability |
| **Eagle Security Audit** | review | Deep vulnerability hunting — injection, auth, data exposure, supply chain |
| **Eagle Architecture Review** | review | Structural health — dependencies, coupling, cohesion, design patterns |
| **Eagle Performance Review** | review | Bottleneck analysis — memory leaks, N+1 queries, bundle bloat |
| **Eagle Code Quality** | review | Readability, dead code, duplication, convention violations, test gaps |
| **Eagle UX Code Review** | review | Frontend code UX — loading states, error handling, form validation |
| **Eagle Accessibility Review** | review | WCAG 2.1 AA compliance — semantic HTML, ARIA, keyboard nav, contrast |
| **Eagle API Review** | review | API design consistency — endpoints, contracts, error handling, versioning |
| **Eagle Data Integrity** | review | Data corruption and loss vectors — race conditions, partial writes |
| **Eagle Database Review** | review | Schema design, query performance, migrations, indexes, ORM usage |

The review skills can output **HTML, Word (.docx), or both**. Product Diagnostics can also export to **Excel (.xlsx)**. Anti-Slop includes Python scripts for automated detection.

Use them independently or combine them: review your product, validate with data, scaffold new projects, and audit your code with autonomous agents.

---

## Table of Contents

- [Eagle UX Review](#eagle-ux-review)
- [Eagle Product Diagnostics](#eagle-product-diagnostics)
- [Eagle Ad Review](#eagle-ad-review)
- [Eagle Anti-Slop](#eagle-anti-slop)
- [Eagle Clean Doc](#eagle-clean-doc)
- [Eagle Clean Sheet](#eagle-clean-sheet)
- [Eagle Multi-Stack Scaffolder](#eagle-multi-stack-scaffolder)
- [Eagle Spectral Agents](#eagle-spectral-agents)
- [Output Formats](#output-formats)
- [The Three-Skill Pipeline](#the-three-skill-pipeline)
- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Built With](#built-with)
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

# Eagle Anti-Slop

**Detects and eliminates AI-generated slop in code, text, and design.**

AI-generated content has a recognizable smell: over-abstracted code, hedge-heavy prose, gradient-drenched design. This skill teaches Claude to spot and fix those patterns across all three domains — so the output reads like it was written by a senior engineer at 2 AM, not a language model trying to sound helpful.

Point Claude at a file, a directory, or a PR diff. It applies a systematic multi-pass review — structural issues first, then naming and comments, then implementation patterns, then language-specific idioms — and rewrites the code to be flatter, leaner, and more direct.

**What it covers:**

| Domain | What it catches |
|--------|----------------|
| **Code** | Wrapper types without value, single-case error enums, happy-path logging, "what" comments, defensive checks for impossible states, unnecessary abstractions, over-engineered error handling |
| **Text** | "Delve into," "navigate the complexities," meta-commentary, hedge clusters, buzzword density, wordy constructions, redundant qualifiers |
| **Design** | AI startup gradients, glassmorphism everywhere, generic stock photos, center-alignment abuse, card overuse, "Empower Your Business" copy |

**10 core principles:**
1. No wrapper types that add indirection without value
2. No defensive code for impossible states
3. No single-case error enums
4. No logging that restates the code
5. No comments that describe what the code does
6. Inline short helpers called once
7. Flat over nested
8. Fewer files over more files
9. Standard library first
10. Test behavior, not implementation

**Bundled scripts:**
- `detect_slop.py` — scans any text or code file, scores 0–100 across 7 categories (high-risk phrases, buzzwords, meta-commentary, hedging, obvious comments, structural red flags), outputs a detailed report with line-level findings
- `clean_slop.py` — automated cleanup with preview mode (default) and `--save` mode. Supports `--aggressive` for transition-word removal and `--output` for writing to a new file

**How it works:** The skill loads domain-specific reference catalogs (code-smells.md, text-smells.md, design-smells.md) based on what you're reviewing. For code, it runs a 4-pass review: structure → naming/comments → implementation → language-specific idioms. For text, it scores against pattern categories and rewrites. For design, it audits against the full visual/UX antipattern catalog.

---

# Eagle Clean Doc

**Modern Word document generation with a clean, monochrome design system.**

The review skills generate HTML by default, which is great for viewing but hard to share. Eagle Clean Doc wraps Claude Code's built-in docx capability with a consistent design system: Helvetica body, Courier New for code, monochrome palette, compact margins, and zero visual clutter.

When you ask any Eagle review skill to output Word format, it uses this design system automatically. You can also use it standalone to generate any Word document.

**Design system:** Helvetica 10.5pt body, Courier New 9.5pt code, black/gray/white only. Compact margins (0.4" top/bottom, 0.5" sides). Clean tables with gray headers. Inline code spans with subtle gray background.

---

# Eagle Clean Sheet

**Modern Excel spreadsheet generation with consistent styling.**

Eagle Clean Sheet applies the same design language to Excel outputs via openpyxl: Helvetica body, Courier New for technical columns, monochrome palette, frozen header rows, and auto-sized columns.

Use it standalone for any spreadsheet task, or as an export format from Product Diagnostics (scorecards, funnels, findings as sortable/filterable data).

**Design system:** Same color tokens as Clean Doc. Gray header rows, thin gray borders, alternating row fills for large datasets. Code font for event names, endpoints, and technical identifiers.

---

# Eagle Multi-Stack Scaffolder

**Research-driven project scaffolding for 13+ technology stacks.**

Most scaffolders spit out a boilerplate template from 2023. This skill researches current best practices via web search BEFORE generating any code, documents every dependency choice with a written justification, and uses modern tooling (Bun for JS/TS, uv for Python, cargo for Rust, SPM for Swift).

**Supported stacks:**

| Category | Stacks |
|----------|--------|
| **Mobile** | SwiftUI (iOS/macOS), Jetpack Compose (Android), Kotlin XML Views, Flutter, Expo React Native |
| **Backend** | Node.js/Express, FastAPI, Flask, Django, Rust/Axum |
| **Web** | Next.js (React), Nuxt.js (Vue) |
| **Architecture** | Turborepo monorepo |

**What you provide:** What you're building, target platforms, and any technology preferences.

**What you get:** Scaffolded project with documentation (RESEARCH.md, DEPENDENCIES.md, STRUCTURE.md, SETUP.md), configuration files, and production-ready boilerplate. Every dependency includes a written justification.

**How it works:** 7-step process — clarify requirements, identify stacks, read reference files, web research for current best practices, generate documentation, scaffold code, verify setup commands.

---

# Eagle Spectral Agents

**14 autonomous agents for code review, debugging, planning, and shipping.** Each agent applies a 3-lens analytical framework and works iteratively — auditing, fixing, and re-auditing until the code passes.

### How agents differ from skills

| | Skills | Agents |
|---|---|---|
| **Invocation** | Slash commands (`/eagle-ux-review`) | Agent tool dispatch (`eagle-spectral-suite`) |
| **Install location** | `~/.claude/skills/<name>/SKILL.md` | `~/.claude/agents/<name>.md` |
| **Behavior** | Follow structured workflows with user input | Autonomous — audit, fix, re-audit in cycles |
| **Best for** | Domain expertise, structured deliverables | Code review, debugging, shipping pipelines |

### Agent categories

**Orchestrator** — `eagle-spectral-suite` detects your intent and tech stack, then dispatches the right specialist agents. Ask it to "review everything" and it figures out which agents to run.

**Lifecycle agents** — for the stages of development:
- `eagle-spectral-plan` — scopes features, evaluates approaches through Feasibility / Risk / Maintainability lenses
- `eagle-spectral-investigate` — root-cause debugging with systematic hypothesis testing
- `eagle-spectral-ship` — pre-ship pipeline: build/test/lint gates, diff review, PR creation

**Review specialists** — each applies 3 domain-specific lenses (Attacker / Ops / Maintainer):
- `eagle-triad-review` — single-pass review covering security + ops + maintainability
- `eagle-security-audit` — vulnerability hunting: injection, auth, data exposure, supply chain
- `eagle-architecture-review` — structural health: coupling, cohesion, dependency direction
- `eagle-performance-review` — bottlenecks: memory leaks, N+1 queries, bundle bloat
- `eagle-code-quality` — readability, dead code, duplication, test gaps
- `eagle-ux-code-review` — frontend code UX: loading states, error handling, form validation
- `eagle-accessibility-review` — WCAG 2.1 AA: semantic HTML, ARIA, keyboard nav, contrast
- `eagle-api-review` — endpoint consistency, contracts, error handling, versioning
- `eagle-data-integrity` — race conditions, partial writes, missing transactions
- `eagle-database-review` — schema design, query performance, migrations, indexes

---

# Output Formats

All three review skills (UX Review, Product Diagnostics, Ad Review) support multiple output formats. Claude will ask during context gathering, or you can specify upfront:

| Format | Extension | Best for | Available in |
|--------|-----------|----------|--------------|
| HTML | `.html` | Interactive viewing, embedded screenshots | All review skills |
| Word | `.docx` | Sharing with stakeholders, email attachments | All review skills |
| Excel | `.xlsx` | Sorting/filtering data, further analysis | Product Diagnostics |

**How to choose:**
- Say nothing → HTML (default)
- Say "word", "doc", "docx", or "shareable" → Word
- Say "both" → HTML + Word
- Say "excel" or "spreadsheet" → Excel (Product Diagnostics only)
- Say "all" → HTML + Word + Excel

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

Interactive installer — choose which skills and agents to install:

```bash
npx eagle-skills install
```

Or without npm:

```bash
curl -fsSL https://raw.githubusercontent.com/eagleisbatman/eagle-skills/main/install.sh | bash
```

The installer clones the repo to `~/.eagle-skills` and symlinks your selections:
- Skills → `~/.claude/skills/<name>/` (directory symlinks)
- Agents → `~/.claude/agents/<name>.md` (file symlinks)

Symlinked items update in place when you run `npx eagle-skills update`.

### Managing your installation

```bash
npx eagle-skills update      # Pull latest changes
npx eagle-skills status      # Show installed skills/agents, check for updates
npx eagle-skills uninstall   # Remove skills, agents, and optionally the repo
```

### Manual install

If you prefer to manage it yourself:

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills

# Skills (symlink directories)
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
ln -sf "$(pwd)/eagle-product-diagnostics" ~/.claude/skills/eagle-product-diagnostics
ln -sf "$(pwd)/eagle-ad-review" ~/.claude/skills/eagle-ad-review
ln -sf "$(pwd)/eagle-anti-slop" ~/.claude/skills/eagle-anti-slop
ln -sf "$(pwd)/eagle-clean-doc" ~/.claude/skills/eagle-clean-doc
ln -sf "$(pwd)/eagle-clean-sheet" ~/.claude/skills/eagle-clean-sheet
ln -sf "$(pwd)/eagle-multi-stack-scaffolder" ~/.claude/skills/eagle-multi-stack-scaffolder

# Agents (symlink .md files)
mkdir -p ~/.claude/agents
for agent in agents/eagle-*.md; do
  ln -sf "$(pwd)/$agent" ~/.claude/agents/$(basename "$agent")
done
```

Update with `git pull`. Symlinks mean installed items update automatically.

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

Skills activate automatically when Claude detects matching intent. You can also invoke them directly with slash commands:

```
/eagle-ux-review
/eagle-product-diagnostics
/eagle-ad-review
/eagle-anti-slop
/eagle-clean-doc
/eagle-clean-sheet
/eagle-multi-stack-scaffolder
```

Agents are dispatched by Claude's Agent tool. Ask Claude to run one by name (e.g., "run eagle-spectral-suite") or describe what you need and the orchestrator will pick the right agent.

### Eagle UX Review

**Required inputs** (Claude will ask for these):
- North star metric (e.g., D7 retention, conversion rate)
- Target user profile (demographics, tech literacy, device/connectivity)
- 2-3 reference apps the target user opens daily
- App identity (chat, marketplace, tool, social, etc.)
- Screen recording (video) OR a folder of screenshots

**Optional inputs** (improve review quality significantly):
- PRD or hypothesis document
- User personas
- Analytics data or competitive screenshots

**Output:** HTML and/or Word report in your working directory with severity-rated findings, embedded evidence screenshots, before/after mockups, priority matrix, and UX law citations. Default is HTML; say "word" or "both" for Word output.

**Example session:**
```
You:   UX review this app — here's a screen recording of the onboarding flow
Claude: [asks for north star metric, target user, reference apps, app identity]
You:   North star is D7 retention. Target users are smallholder farmers in India,
       low-tech literacy, Android devices on 2G/3G. Reference apps: WhatsApp, YouTube.
       It's a chat app.
Claude: [extracts frames at 1fps, analyzes against 65+ UX laws, generates HTML report]
```

### Eagle Product Diagnostics

**Required inputs:**
- Goal definitions (success metrics per feature)
- Event taxonomy (analytics events mapped to screens and funnels)
- Database outcomes (actual vs. target metrics)

**Optional inputs:**
- A UX review report (from Eagle UX Review) for per-finding validation

**Output:** HTML, Word, and/or Excel report with goal scorecard (PASS/FAIL/PARTIAL per layer), funnel visualizations, three-layer diagnosis per feature, disagreement analysis, and prioritized actions. Default is HTML; say "word", "excel", "both", or "all" for other formats.

**Example session:**
```
You:   Why isn't our onboarding completion rate improving? Here's our Firebase
       events export and the DB metrics.
Claude: [asks for goal definitions, event-to-screen mapping, target metrics]
You:   [provides event taxonomy CSV, DB query results, and links the UX review]
Claude: [triangulates design intent vs. behavior vs. outcomes, generates HTML report]
```

### Eagle Ad Review

**Required inputs:**
- Campaign strategy (objective, funnel stage, audience, medium/channels, KPI)
- Brand context (value proposition, positioning, competitive landscape)
- Creative files (images, videos, audio, PDFs, scripts — any format, any medium)

**Output:** HTML and/or Word report with 10-dimension scoring (weighted by campaign type and medium), per-creative breakdowns, best/worst performer galleries, cross-cutting findings, platform compliance audit, and a creative brief for the next round. Default is HTML; say "word" or "both" for Word output.

**Example session:**
```
You:   Review these ad creatives — folder is ./ads/. Campaign is awareness for
       rural farmers in UP, running on Meta and local radio.
Claude: [asks for campaign objective, funnel stage, audience details, brand context]
You:   [provides strategy and brand positioning]
Claude: [catalogs all files, scores against Meta ABCD + Kantar + medium-specific
        best practices, generates HTML report]
```

### Eagle Anti-Slop

**No required inputs** — just point it at code, text, or a design.

**Output:** Cleaned files with slop removed. For code: refactored in-place with explanations. For text: scored report + cleaned version. For design: audit against the antipattern catalog.

**Example sessions:**
```
You:   Review this file for slop
Claude: [runs 4-pass code review, identifies wrapper types, happy-path logs,
        "what" comments — rewrites to be leaner]

You:   Clean up the AI-generated text in ./docs/
Claude: [scores each file, previews changes, applies cleanup with --save]

You:   Is this landing page design sloppy?
Claude: [audits against design-smells catalog — gradient overuse, generic copy,
        card-within-card nesting — recommends specific fixes]
```

**Bundled scripts** (can also be run standalone):
```bash
# Scan a file and get a slop score (0-100)
python eagle-anti-slop/scripts/detect_slop.py myfile.txt

# Preview what would change
python eagle-anti-slop/scripts/clean_slop.py myfile.txt

# Apply cleanup
python eagle-anti-slop/scripts/clean_slop.py myfile.txt --save

# Aggressive mode (removes transition words too)
python eagle-anti-slop/scripts/clean_slop.py myfile.txt --save --aggressive
```

### Eagle Multi-Stack Scaffolder

**Required inputs:**
- What you're building (app type, features, target platforms)

**Optional inputs:**
- Technology preferences, existing backend/services to integrate with

**Output:** Complete project scaffold with documentation and boilerplate for each stack.

**Example session:**
```
You:   I want to build a fitness tracking app for iOS and Android with a Python backend
Claude: [identifies stacks: Expo React Native + FastAPI, reads reference files,
        researches current best practices, generates docs + scaffold]
```

### Eagle Spectral Agents

Agents work autonomously — tell Claude what you need and the right agent runs:

```
You:   Review this codebase for security issues
Claude: [dispatches eagle-security-audit → iterative 3-lens audit → fixes → report]

You:   Help me plan this feature
Claude: [dispatches eagle-spectral-plan → forcing questions → approach evaluation → plan]

You:   Ship this
Claude: [dispatches eagle-spectral-ship → build/test/lint gates → PR creation]

You:   Run a full review
Claude: [dispatches eagle-spectral-suite → detects stack → runs relevant specialists]
```

---

## Built With

- **[Claude Code Skills & Agents](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's systems for extending Claude with domain expertise and autonomous capabilities
- **ffmpeg** — video frame extraction at configurable intervals
- **65+ UX laws** curated from established HCI research: Medhi et al. (2011), Nielsen (1994), Gestalt psychology, Fitts (1954), GSMA Mobile for Development, and more
- **Three-layer triangulation framework** combining UX analysis, behavioral analytics, and outcome data
- **Ad creative effectiveness research** from Meta ABCD, Kantar (200K+ ad database), System1, Nielsen, IPA Databank (1,400+ case studies)
- **Platform-specific ad specs** for Meta, Google, TikTok, LinkedIn, X, and Pinterest
- **Anti-slop pattern catalogs** covering code (Swift, Python, TS/JS, Java), natural language, and visual/UX design
- **Spectral 3-lens framework** — every review agent applies Attacker / Ops / Maintainer perspectives in iterative audit cycles
- **13+ stack references** for the scaffolder: SwiftUI, Jetpack Compose, Flutter, Expo RN, FastAPI, Django, Flask, Node/Express, Rust/Axum, Next.js, Nuxt.js, monorepo

---

## License

MIT
