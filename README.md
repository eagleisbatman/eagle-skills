# Eagle Skills

<!-- Badges placeholder — uncomment and update when applicable
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet)
-->

Custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's agentic coding tool. Each skill extends Claude with domain-specific expertise, structured workflows, and production-quality deliverables.

---

## Table of Contents

- [Eagle UX Review](#eagle-ux-review)
- [How It Works](#how-it-works)
- [Report Preview](#report-preview)
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

## Installation

### Option A: Symlink (recommended)

Keeps the skill linked to this repo so you get updates with `git pull`:

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cd eagle-skills
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
```

**Pros:** Updates automatically when you pull. Single source of truth.
**Cons:** Breaks if you move or delete the cloned repo.

### Option B: Copy

Standalone installation, independent of this repo:

```bash
git clone https://github.com/eagleisbatman/eagle-skills.git
cp -r eagle-skills/eagle-ux-review ~/.claude/skills/
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

Once installed, trigger the skill with natural language in Claude Code:

```
ux review this screen recording
```
```
critique this design — here are the screenshots
```
```
run a heuristic evaluation of our onboarding flow
```
```
UX audit — I'll provide a PRD and video walkthrough
```

**Trigger phrases:** `ux review`, `ux audit`, `critique this design`, `heuristic evaluation`, `usability review`, `teardown`, `analyze this screen`

The skill activates automatically when Claude detects UX evaluation intent.

---

## Built With

- **[Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code)** — Anthropic's skill system for extending Claude with domain expertise via `SKILL.md` definitions
- **ffmpeg** — video frame extraction at configurable intervals
- **65+ UX laws** curated from established HCI research, organized into actionable audit checklists

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
