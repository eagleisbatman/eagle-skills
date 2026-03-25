# Eagle Skills

Custom Claude Code skills for specialized workflows.

## Skills

### [eagle-ux-review](./eagle-ux-review/)

Expert-level UX reviews grounded in 55+ UX laws and principles. Produces structured, severity-rated HTML reports with embedded screenshots, visual design mockups, and actionable recommendations tied to business metrics.

**Features:**
- Video frame extraction at 1-second intervals (captures transitions 2s misses)
- PRD/hypothesis validation against observed user behavior
- Structured context gathering: north star metrics, personas, analytics, competitive analysis
- HTML report with brutalist styling: findings, priority matrix, current-vs-proposed mockups
- 55+ UX laws reference organized by category
- Mobile-first analysis with low-literacy audience considerations
- AI-specific UX principles (streaming, turn length, suggestion chips)

**Trigger phrases:** `ux review`, `ux audit`, `critique this design`, `heuristic evaluation`, `usability review`, `teardown`, `analyze this screen`

## Installation

Copy the desired skill directory to `~/.claude/skills/`:

```bash
cp -r eagle-ux-review ~/.claude/skills/
```

Or symlink for automatic updates:

```bash
ln -sf "$(pwd)/eagle-ux-review" ~/.claude/skills/eagle-ux-review
```

## License

MIT
