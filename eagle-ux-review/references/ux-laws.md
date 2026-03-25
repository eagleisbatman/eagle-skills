# UX Laws & Principles Reference

Comprehensive catalog of 65+ UX laws organized by 12 categories. For every review, scan every law against every screen/flow. Not every law applies — but every law must be considered.

---

## 1. HEURISTICS & DECISION PRINCIPLES

### Jakob's Law
Users spend most of their time on OTHER apps. They expect your app to work the same way.
- **Audit:** Identify user's top 3 daily apps. Compare layout, interaction patterns, navigation paradigm.
- **Key question:** Does this app match the patterns of apps the user already knows?
- **Common violations:** Custom navigation, non-standard input methods, unfamiliar gesture controls.
- **Mobile-specific:** Check against platform conventions (iOS HIG, Material Design).

### Fitts's Law
Time to acquire a target is a function of the distance to and size of the target.
- **Audit:** Measure primary CTA size (min 44x44pt iOS, 48x48dp Android). Check thumb zone reachability.
- **Key question:** Is the primary action the easiest thing to tap?
- **Common violations:** Small tap targets, primary CTAs far from thumb zone, equal-weight buttons.
- **Low-literacy note:** Larger targets reduce error for users unfamiliar with precise touch.

### Hick's Law (Hick-Hyman Law)
Decision time increases logarithmically with the number and complexity of choices.
- **Audit:** Count choices per screen. Flag any screen with >3 competing actions.
- **Key question:** How many decisions must the user make at each step?
- **Common violations:** Too many nav items, multiple equal-weight CTAs, mode selection gates.
- **Formula:** RT = a + b × log2(n) where n = number of choices.

### Miller's Law
Average person holds 7 (±2) items in working memory.
- **Audit:** Count information units per screen. Verify chunking and grouping.
- **Key question:** How many things must the user remember simultaneously?
- **Common violations:** Long forms without progress, menus with 10+ items, dense screens without chunking.
- **Low-literacy note:** Effective capacity drops significantly. Target 3-4 items max.

### Parkinson's Law
Work expands to fill the time available for its completion.
- **Audit:** Time each flow. Compare to user expectation. Check for progress indicators.
- **Key question:** Does the UI make tasks feel faster than expected?
- **Common violations:** No time estimates, overly complex flows, open-ended processes.

### Occam's Razor
Among competing solutions, the simplest is usually best.
- **Audit:** For each element, ask: what happens if this is removed?
- **Key question:** Can anything be removed without losing function?
- **Common violations:** Feature bloat, unnecessary steps, decorative UI that doesn't aid comprehension.

### Paradox of the Active User
Users never read manuals; they start using software immediately.
- **Audit:** Can a new user complete the core task within 30 seconds of first open?
- **Key question:** Can a first-time user figure this out without instructions?
- **Common violations:** Tutorial-blocking onboarding, instruction text as crutch, tooltips for core features.

### Law of Least Effort (Zipf's Law)
Users will choose the path requiring the least effort.
- **Audit:** Is the most common action also the easiest action?
- **Key question:** Does the UI make the frequent task trivially easy?
- **Common violations:** Burying common actions in menus, requiring multiple taps for frequent operations.

---

## 2. GESTALT PRINCIPLES (Visual Perception)

### Law of Proximity
Objects close together are perceived as related.
- **Audit:** For each label/action, check spatial proximity to its subject.
- **Common violations:** Labels far from fields, actions far from context, mixed groupings.

### Law of Similarity
Elements that look similar are perceived as related.
- **Audit:** Inventory interactive elements. Check visual consistency within types.
- **Common violations:** Buttons that look alike but do different things, inconsistent same-type styling.

### Law of Common Region
Elements within a shared boundary are perceived as a group.
- **Audit:** Map visual containers to functional groups. Flag mismatches.
- **Common violations:** Functional elements split across regions, unrelated items in same container.

### Law of Pragnanz (Simplicity)
People perceive ambiguous images in the simplest form possible.
- **Audit:** Squint test — what do you see first? Is that the most important element?
- **Common violations:** Cluttered layouts, ambiguous hierarchy, competing focal points.

### Law of Uniform Connectedness
Elements visually connected (lines, colors, frames) are perceived as more related.
- **Audit:** Trace visual connections. Verify they match information architecture.
- **Common violations:** Visual connections between unrelated items, missing connections between related items.

### Law of Closure
People fill in missing information to perceive a complete object.
- **Audit:** Check truncated/partial elements for clear continuation signals.
- **Common violations:** Truncated content with no "more" signal, ambiguous affordances.

### Law of Figure-Ground
People perceive objects as either foreground or background.
- **Audit:** Check contrast ratios. Verify interactive elements pop from background.
- **Common violations:** Low contrast between interactive/non-interactive, unclear modal separation.

### Law of Common Fate
Elements moving in the same direction are perceived as related.
- **Audit:** Review animations. Check motion groupings match functional groupings.
- **Common violations:** Unrelated elements animating together, related elements animating separately.

### Law of Continuity
Points connected by straight or smoothly curving lines are perceived as grouped.
- **Audit:** Check if visual flow guides the eye along the intended reading/interaction path.
- **Common violations:** Visual elements that break the natural flow, jarring layout transitions.

---

## 3. COGNITIVE BIASES

### Serial Position Effect
People best remember the first (primacy) and last (recency) items in a series.
- **Audit:** In every list/sequence, check: is the most important item first or last?
- **Common violations:** Key info buried mid-list, filler at start/end of flows.

### Von Restorff Effect (Isolation Effect)
The item that stands out is most likely to be remembered.
- **Audit:** Identify the ONE most important element per screen. Is it visually distinct?
- **Common violations:** Everything emphasized (so nothing is), primary CTA blends in.

### Peak-End Rule
People judge experiences by their peak moment and the end, not the average.
- **Audit:** Map emotional curve. Identify peak and end. Rate each.
- **Common violations:** Frustrating endings, no peak moments of delight.

### Anchoring Bias
First piece of information seen biases subsequent decisions.
- **Audit:** What's the first number/value/option the user sees? Does it set the right anchor?
- **Common violations:** Default values that anchor too high/low, pricing shown in wrong order.

### Selective Attention (Banner Blindness)
People focus on specific stimuli while ignoring others.
- **Audit:** Identify elements resembling patterns users typically ignore (banners, footers, sidebars).
- **Common violations:** Important info in banner positions, critical alerts styled as ads.

### Status Quo Bias
Users resist change and prefer the current state.
- **Audit:** For any change in flow/layout, is there a gradual transition?
- **Common violations:** Radical UI changes without onboarding, removing familiar features without explanation.

### Confirmation Bias
Users see what they expect to see.
- **Audit:** Does the UI match what the user expects based on their mental model?
- **Common violations:** Unexpected content in familiar containers, actions that do something different than expected.

### Framing Effect
How information is presented affects decisions, even with identical data.
- **Audit:** Check how options/features/prices are framed. Positive or negative framing?
- **Common violations:** Negative framing of positive features, unclear benefit statements.

---

## 4. RESPONSE TIME & FEEDBACK

### Doherty Threshold
Productivity soars when response time is <400ms.
- **Audit:** Time every interaction. Flag >400ms without feedback. Flag >2s without progress. Flag >10s without rich feedback.
- **Key question:** Does every interaction respond within 400ms? If not, is there meaningful feedback?
- **Common violations:** No loading indicators, spinners without progress signal, no streaming for AI responses.
- **Thresholds:** 0-100ms = instant. 100-400ms = noticeable but fine. 400ms-1s = needs feedback. 1-10s = needs progress. >10s = needs rich engagement.

### Response Time Limits (Jakob Nielsen)
- **0.1s** — System feels instantaneous
- **1.0s** — User's flow of thought stays uninterrupted
- **10s** — Limit for keeping user's attention
- **Audit:** Categorize every interaction into these buckets. Flag violations.

### Skeleton Screens
Placeholder layouts that show content structure before data loads.
- **Audit:** During loading, does the UI show the shape of what's coming?
- **Common violations:** Blank screens, spinners with no structural preview.

---

## 5. COMPLEXITY & INFORMATION

### Tesler's Law (Conservation of Complexity)
Every system has inherent complexity that cannot be removed — only shifted between user and system.
- **Audit:** For each user decision, ask: could the system make this automatically?
- **Common violations:** Exposing technical decisions to non-technical users, manual config that could be auto-detected.

### Postel's Law (Robustness Principle)
Be liberal in what you accept, conservative in what you send.
- **Audit:** Test with typos, partial input, wrong formats. Does the system help or block?
- **Common violations:** Rigid validation, no autocorrect/suggest, breaking on edge cases.

### Information Foraging Theory
Users will expend effort proportional to the expected value of the information.
- **Audit:** Does each screen clearly signal what value lies ahead? Are "information scent" cues strong?
- **Common violations:** Generic labels, unclear what tapping a link/button will reveal, dead-end screens.

### Progressive Disclosure
Show only essential information first, reveal details on demand.
- **Audit:** Is the initial view simple? Can users drill down for more?
- **Common violations:** All info dumped on one screen, hidden critical features, no layering.

### Cognitive Load Theory (Sweller)
Three types: intrinsic (task complexity), extraneous (poor design), germane (learning).
- **Audit:** Identify and minimize extraneous load. Is the interface adding unnecessary processing?
- **Common violations:** Decorative elements that don't aid comprehension, redundant information, split attention between related elements.

---

## 6. ENGAGEMENT & BEHAVIOR

### Goal Gradient Effect
Motivation increases as one gets closer to a goal.
- **Audit:** Check every multi-step flow for progress visualization.
- **Common violations:** No progress indicators, long flows with no milestones.

### Zeigarnik Effect
People remember uncompleted tasks better than completed ones.
- **Audit:** At flow end, is there a reason for the user to come back?
- **Common violations:** No saved state, conversations that feel "complete" with no follow-up.

### Endowment Effect
People value things more once they feel ownership.
- **Audit:** After 5 sessions, what does the user "own" in this app?
- **Common violations:** No user-generated content, no history, no personalization.

### Variable Reward (Hook Model — Nir Eyal)
Unpredictable rewards drive engagement more than predictable ones.
- **Audit:** Check if content/responses vary between sessions.
- **Three types:** Tribe (social), Hunt (resources/info), Self (mastery/completion).

### Loss Aversion
People prefer avoiding losses to acquiring equivalent gains.
- **Audit:** Check for "you'll lose X" framing. Use ethically.
- **Common violations:** No streak/progress protection, not showing what's at stake.

### Social Proof
People look to others' behavior to guide their own.
- **Audit:** Can users see that others use this successfully?
- **Common violations:** No community signals, no "X people asked this," no ratings.

### Commitment & Consistency
Once people commit to something, they're more likely to follow through.
- **Audit:** Is there a small initial commitment that drives larger engagement?
- **Common violations:** No onboarding investment, no micro-commitments.

### Aesthetic-Usability Effect
Users perceive aesthetically pleasing designs as more usable.
- **Audit:** Screenshot every screen. Rate polish 1-5. Flag anything <3.
- **Common violations:** Placeholder content, inconsistent styling, broken layouts.

### IKEA Effect
People value things more when they've invested labor in creating them.
- **Audit:** Does the app involve the user in creating/customizing something?
- **Common violations:** Fully pre-built experiences with no user investment.

---

## 7. MOBILE-SPECIFIC PRINCIPLES

### Thumb Zone
Most one-handed usage happens in the natural thumb arc.
- **Audit:** Overlay thumb zone map on screenshots. Flag primary actions outside zone.
- **Zones:** Easy (bottom center), OK (sides/upper-center), Hard (top corners).

### Bottom Navigation Principle
Primary navigation should be at the bottom on mobile.
- **Audit:** Check nav position against platform conventions.
- **Standard:** iOS tab bar (bottom), Android bottom nav (Material).

### Content-First Mobile
Mobile screens should prioritize content over chrome.
- **Audit:** Calculate content-to-chrome ratio. Target >60% content.
- **Common violations:** Oversized headers, persistent toolbars consuming half the screen.

### Touch Target Size
Minimum 44x44pt (Apple HIG) or 48x48dp (Material Design).
- **Audit:** Measure all tap targets. Flag anything under minimum.
- **Low-literacy note:** Increase minimums to 56dp+ for users with less touchscreen precision.

### Offline-First Consideration
In low-connectivity environments, design for offline/degraded states.
- **Audit:** Test on 2G/3G. Check for offline states, cached content, graceful degradation.
- **Common violations:** App completely breaks offline, no cached content, no error states.

### One-Handed Operation
Most mobile usage is one-handed.
- **Audit:** Can all primary actions be completed one-handed? Bottom-first layout?
- **Common violations:** Actions requiring two-handed stretches, top-of-screen critical buttons.

### Interruption Recovery
Mobile users are frequently interrupted.
- **Audit:** What happens when the user switches apps and returns? Is state preserved?
- **Common violations:** Lost input, reset forms, lost scroll position.

---

## 8. ACCESSIBILITY & INCLUSION

### WCAG Contrast Ratios
Text must meet minimum contrast ratios against backgrounds.
- **Standard:** 4.5:1 for normal text, 3:1 for large text (WCAG AA).
- **Audit:** Check all text/background combinations. Flag failures.

### Perceivable Information
Information must not rely on a single sensory channel.
- **Audit:** Is color the only indicator of state? Do icons have labels?
- **Common violations:** Red/green only status, icon-only buttons with no labels.

### Operable Controls
All interactive elements must be usable by all users.
- **Audit:** Can all actions be completed via keyboard/assistive tech? Are touch targets adequate?
- **Common violations:** Custom controls that break accessibility, gesture-only interactions.

### Understandable Content
Content must be readable and predictable.
- **Audit:** Readability level (target 5th grade for general audiences, 3rd grade for low-literacy). Predictable navigation.
- **Common violations:** Jargon, inconsistent navigation, unexpected behavior.
- **Low-literacy note:** Use simple words, short sentences, icons with labels, visual cues over text.

### Error Prevention (Nielsen Heuristic #5)
Design to prevent errors, not just report them.
- **Audit:** Are destructive actions guarded? Do inputs validate in real-time?
- **Common violations:** No confirmation for irreversible actions, post-submission-only validation.

---

## 9. NIELSEN'S 10 USABILITY HEURISTICS

Quick-reference checklist — apply to every screen:

1. **Visibility of System Status** — Is the user always informed of what's happening?
2. **Match Between System and Real World** — Does the system use the user's language and concepts?
3. **User Control and Freedom** — Can the user undo, redo, and escape easily?
4. **Consistency and Standards** — Do similar elements behave consistently?
5. **Error Prevention** — Does the design prevent errors before they occur?
6. **Recognition Rather Than Recall** — Are options visible rather than requiring memory?
7. **Flexibility and Efficiency of Use** — Are there shortcuts for experienced users?
8. **Aesthetic and Minimalist Design** — Does every element serve a purpose?
9. **Help Users Recognize, Diagnose, and Recover from Errors** — Are error messages clear and actionable?
10. **Help and Documentation** — Is help available when needed, in context?

---

## 10. AI-SPECIFIC PRINCIPLES

### Expectation Setting
Users need to know what the AI can and cannot do.
- **Audit:** Does the interface communicate capabilities and limitations?
- **Common violations:** Overpromising in marketing, no scope indication, no confidence signals.

### Streaming & Progressive Response
AI responses should stream to reduce perceived latency.
- **Audit:** Does text appear token-by-token, or all-at-once after a long wait?
- **Common violations:** "Getting your answer..." spinners for 10+ seconds, no streaming.

### Conversational Turn Length
AI chat responses should match the conversational register of the target user.
- **Audit:** Compare AI response length/complexity to typical messages in the user's reference chat app.
- **Common violations:** Essay responses in chat interfaces, formal language for casual audiences.

### Suggestion Chips / Conversation Hooks
Follow-up prompts drive continued engagement.
- **Audit:** After every AI response, are there clear next actions?
- **Common violations:** Dead-end responses, no follow-up suggestions, user must compose from scratch.

### Graceful AI Failure
When AI doesn't know, it should fail helpfully.
- **Audit:** What happens when AI can't answer? Does it redirect, suggest alternatives?
- **Common violations:** Silent failure, generic "I don't know," no fallback path.

---

## 11. LOW-LITERACY & EMERGING MARKET DESIGN

*Sources: Medhi et al. (2011) "Designing Mobile Interfaces for Novice and Low-Literacy Users" (ACM TOCHI), GSMA Mobile for Development design guidelines, Indrani Medhi-Thies (Microsoft Research India), Kentaro Toyama "Geek Heresy" (2015)*

### Visual Primacy
Low-literacy users rely on images, icons, and colors as their primary means of navigation and comprehension, rather than text.
- **Key question:** Can a user who cannot read navigate and use this app purely through visual elements?
- **Audit:** Cover all text on each screen: can you still understand what to do? Check that every navigation item has a recognizable, realistic icon. Verify content has supporting imagery (photographs > illustrations > icons).
- **Common violations:** Text-only navigation, abstract icon-only interfaces, reliance on text labels, text-heavy content screens, menus with no visual differentiation.
- **Design principle:** Text should confirm what visuals already communicate, not carry the primary information load. Use photographs of real objects. Use color-coding consistently. Use spatial layout to convey meaning.

### Audio/Voice as Primary Interface
For users who cannot read well, audio (both input and output) should be a first-class interaction mode, not an afterthought.
- **Key question:** Can the user complete the core task flow entirely through voice/audio?
- **Audit:** Map the core task flow: can each step be completed via voice? Check text-to-speech availability. Check voice input quality, error handling, and language support. Verify voice recording UI is discoverable with clear start/stop/cancel states.
- **Common violations:** Voice input as a hidden feature, no text-to-speech for content, voice features require reading instructions to activate.
- **Design principle:** The voice input button should be the MOST prominent interaction element, not a small microphone icon. Provide audio playback for all content. Support the user's local language/dialect.

### Concrete Over Abstract
Low-literacy users understand concrete, real-world representations better than abstract symbols or metaphors. — Medhi et al., 2011
- **Key question:** Are visual elements realistic (photographic) rather than abstract (iconographic)?
- **Audit:** Inventory all icons and images: realistic/photographic or abstract/stylized? Check if metaphors require prior digital literacy (gear = settings, cloud = storage, hamburger = menu). Verify images match the user's local context.
- **Common violations:** Abstract icons for concepts with real-world equivalents, metaphors requiring cultural knowledge, stylized illustrations instead of photographs.
- **Design principle:** Use photographs of actual crops, pests, equipment matching the user's local context. Localize images as well as text. Avoid abstract icons for core functionality.

### Minimal Text, Maximum Meaning
Every word must earn its place. Use the shortest possible text that conveys the full meaning. Support text with visuals.
- **Key question:** Is every text element as short as it can be while remaining clear?
- **Audit:** Check reading level of all UI text (target: grade 3-5). Count words per label/instruction (aim for 1-3 words). Verify every text element has visual support.
- **Common violations:** Long sentences where short phrases suffice, technical vocabulary, complex grammar, paragraph-format instructions, text without visual support.
- **Design principle:** Write for a 3rd-grade reading level in the local language. Use active voice, short sentences. "Take a photo of the sick leaf" not "Please capture an image of the affected foliage for analysis."

### Guided Linear Flows
Low-literacy users perform better with step-by-step linear flows than with open-ended interfaces requiring wayfinding decisions. — Medhi et al., 2011
- **Key question:** Does the interface guide the user through a clear sequence of steps, or require them to figure out where to go?
- **Audit:** Map the core flow: is it linear (Step 1 → Step 2 → Step 3) or branching? Check for clear "what to do next" signals on every screen. Verify the user never reaches a dead-end.
- **Common violations:** Dashboard/hub screens with multiple equal options, non-linear navigation requiring wayfinding, flows that branch based on user decisions, interfaces that assume the user knows what to do next.
- **Design principle:** The ideal flow: open app → single input (voice or photo) → get answer → optional follow-up → done. Avoid hub-and-spoke patterns. Make the most common path visually dominant.

### Meaningful Defaults
Pre-select the most common or safest option so the user can proceed with minimal decisions.
- **Key question:** Are intelligent defaults set for every configurable option?
- **Audit:** Check every selection/input: is the most common option pre-selected? Check language auto-detection, location auto-detection, and relevant content based on user history.
- **Common violations:** Empty dropdowns, no pre-selected options, settings with no defaults, language selection with no auto-detection, requiring manual input when the system has the data.
- **Design principle:** Auto-detect everything possible: language, location, crop season, relevant content. Every decision removed is one less point of confusion.

### Error Tolerance & Forgiveness
The interface should be extraordinarily forgiving of user errors, especially for users unfamiliar with digital interfaces.
- **Key question:** If the user taps the wrong thing or enters wrong information, how quickly and painlessly can they recover?
- **Audit:** Test every possible error path: wrong taps, wrong inputs, back-button, home-button, accidental dismissals. Verify all errors are recoverable in 1-2 taps. Check that no user data is lost on error.
- **Common violations:** Destructive actions without undo, one-way flows with no back option, error states requiring technical knowledge, form data lost on error.
- **Design principle:** Assume the user WILL tap the wrong thing. Design so wrong taps are harmless and reversible. Use confirmation for destructive actions with visual (not text-heavy) dialogs. Auto-save everything.

### Familiar Metaphors from Daily Life
Use interaction patterns from apps the user already knows (WhatsApp, YouTube, phone dialer) rather than novel patterns.
- **Key question:** Would a user whose only apps are WhatsApp and YouTube understand this interface immediately?
- **Audit:** List the top 3 apps used by the target audience. For each pattern in the reviewed app, check: does it match one of those reference apps? Flag every pattern that requires learning something new.
- **Common violations:** Novel navigation patterns, custom gesture vocabularies, unfamiliar content layouts, interaction models from desktop software.
- **Design principle:** WhatsApp is the dominant reference for most emerging market users. Its patterns ARE "the internet" for this audience: bottom input field, send button, voice message via hold-to-record, conversations flow upward, green = connected, blue = read.

---

## 12. UX METRICS & KPIs

*Use these metrics to quantify UX quality, set targets, and measure improvement. Each metric maps to specific UX principles.*

### Efficiency Metrics

| Metric | What It Measures | Target | Related Principles |
|--------|-----------------|--------|-------------------|
| **Task Success Rate** | % of users who complete a core task | >85% | Hick's Law, Error Prevention, User Control |
| **Time on Task** | Seconds to complete core task | Varies (shorter = better) | Doherty Threshold, Parkinson's, Fitts's |
| **Error Rate** | Errors per task attempt | <0.5 per task | Error Prevention, Postel's Law, Error Tolerance |
| **Taps to Complete** | Number of taps for core task | <5 for simple tasks | Hick's Law, Occam's Razor, Guided Linear Flows |
| **Time to First Value** | Seconds from first open to first valuable interaction | <30s for chat apps | Goal Gradient, Doherty Threshold |
| **Learnability** | Improvement in task time across sessions | Plateau by session 3 | Jakob's Law, Recognition vs Recall |

### Engagement Metrics

| Metric | What It Measures | Target | Related Principles |
|--------|-----------------|--------|-------------------|
| **DAU/MAU Ratio** | Daily active / monthly active users | >20% for utility apps | Hook Model, Zeigarnik, Variable Reward |
| **Session Length** | Average time per session | Varies by app type | Peak-End Rule, Content-First Mobile |
| **Session Frequency** | Sessions per user per week | >3 for retention | Hook Model, Loss Aversion, Social Proof |
| **D1/D7/D30 Retention** | % of users returning at day 1/7/30 | D1>40%, D7>20%, D30>10% | Endowment Effect, Hook Model, Commitment |
| **Queries per Session** | (For AI/chat apps) questions asked per session | >2 | Zeigarnik, Suggestion Chips |

### Satisfaction Metrics

| Metric | How to Measure | Related Principles |
|--------|---------------|-------------------|
| **SUS (System Usability Scale)** | 10-question standardized survey (0-100) | All heuristics |
| **NPS (Net Promoter Score)** | "How likely to recommend?" (0-10) | Aesthetic-Usability, Peak-End |
| **CES (Customer Effort Score)** | "How easy was it?" (1-7 scale) | Tesler's Law, Hick's, Cognitive Load |
| **CSAT (Customer Satisfaction)** | Post-interaction rating (1-5 stars) | Error Recovery, Doherty Threshold |

---

## HOW TO USE THIS REFERENCE

**Per-Screen Process:**
1. Run through ALL categories mentally (2-3 minutes per screen once practiced)
2. Flag violations with severity: Critical / High / Medium / Low
3. Tie each violation to the north star metric
4. Propose a fix grounded in the law's principle
5. Compare to reference apps

**Per-Flow Process:**
1. Map emotional curve (Peak-End Rule)
2. Check for open loops (Zeigarnik)
3. Measure time-to-first-value (Doherty + Parkinson's)
4. Verify identity consistency (Jakob's Law at app level)
5. Count decisions per step (cumulative Hick's Law)
6. Assess behavioral mode: is the app training active or passive behavior?

**Low-Literacy Audience Additional Checks:**
1. Cover-the-text test: can you understand the screen without reading? (Tests Visual Primacy)
2. Voice-only test: can the core task be completed entirely by voice? (Tests Audio/Voice)
3. Familiar-app test: does this feel like WhatsApp/YouTube? (Tests Familiar Metaphors)
4. One-path test: is there exactly one obvious thing to do next? (Tests Guided Linear Flows)
5. Wrong-tap test: what happens if you tap the wrong thing? (Tests Error Tolerance)
