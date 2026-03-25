# Goal Definition Template

Fill out one section per feature/flow you want to validate. The more specific the targets, the more useful the diagnosis.

---

## Feature: [Feature Name]

**Description:** [One sentence — what does this feature do for the user?]

**User Story:** As a [user type], I want to [action] so that [benefit].

**Success Definition:** [What does "working" look like? Be specific.]

**Target Metric:**

| Metric | Current Value | Target Value | Measurement Window |
|--------|--------------|-------------|-------------------|
| [e.g., task completion rate] | [e.g., 35%] | [e.g., 70%] | [e.g., per session] |
| [e.g., time to complete] | [e.g., 90s] | [e.g., 30s] | [e.g., median] |
| [e.g., D7 retention of users who used feature] | [e.g., 8%] | [e.g., 25%] | [e.g., cohort] |

**North Star Connection:** [How does this feature's success connect to the overall product metric? e.g., "More completed checkouts → higher revenue/user → better LTV" or "More searches performed → higher content engagement → better retention"]

**Happy Path (Expected User Flow):**
1. [Step 1 — e.g., User opens app]
2. [Step 2 — e.g., User navigates to feature]
3. [Step 3 — e.g., User performs core action]
4. [Step 4 — e.g., System responds / action completes]
5. [Step 5 — e.g., User takes follow-up action or exits]

**Known Risks / Assumptions:**
- [e.g., "Assumes user discovers the feature organically"]
- [e.g., "Depends on network connectivity"]
- [e.g., "Onboarding may not cover this flow"]

---

## Feature: [Next Feature Name]

*(Copy the section above for each additional feature)*

---

## Tips for Filling This Out

- **Be specific about targets.** "Improve retention" is not actionable. "D7 retention from 8% to 20% for users who complete onboarding" is.
- **Include current values.** Without a baseline, there's no way to measure improvement.
- **One feature = one goal.** If a feature serves multiple purposes, split them.
- **The happy path should match your PRD.** If you have a PRD, reference the relevant section.
- **List what could go wrong.** Known risks help the diagnostics skill look for the right failure signals.
