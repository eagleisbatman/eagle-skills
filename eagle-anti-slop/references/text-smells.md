---
name: text-smells
description: Full catalog of AI slop patterns in natural language. Overused phrases, hedge language, meta-commentary, buzzwords, filler constructions, and structural red flags.
---

# Text Slop Patterns

## High-risk phrases (nearly always slop)

Delete on sight:
- "delve into" / "dive deep into"
- "unpack" (when not referring to physical objects)
- "navigate the complexities"
- "in the ever-evolving landscape"
- "in today's fast-paced world"
- "in today's digital age"
- "at the end of the day"
- "it's important to note that"
- "it's worth noting that"
- "in conclusion" (when the conclusion is obvious)

## Medium-risk phrases (context-dependent)

Often filler, sometimes legitimate:
- "however, it is important to"
- "furthermore"
- "moreover"
- "in essence"
- "essentially"
- "fundamentally"
- "ultimately"
- "that being said"

These are fine occasionally. They're slop when every paragraph starts with one.

## Meta-commentary

Self-referential statements that add zero information. Delete the whole sentence:
- "In this article, I will discuss..."
- "As we explore..."
- "Let's take a closer look..."
- "Now that we've covered..."
- "Before we proceed..."
- "It's crucial to understand..."
- "We must consider..."

Just say the thing. Skip the stage directions.

## Buzzwords

### Meaningless modifiers
| Buzzword | What it actually means |
|----------|----------------------|
| "synergistic" | "cooperative" or delete |
| "holistic approach" | "comprehensive" or delete |
| "paradigm shift" | "major change" |
| "game-changer" | "significant" or delete |
| "revolutionary" | almost never true — be specific |
| "cutting-edge" | "advanced" or "new" |
| "next-generation" | "new" |
| "world-class" | "excellent" or delete |
| "best-in-class" | "excellent" or delete |
| "leverage" | "use" |
| "utilize" | "use" |

### Vague action phrases
- "drive innovation" → what innovation, specifically?
- "unlock potential" → whose potential to do what?
- "empower users" → how?
- "enable success" → at what?
- "foster growth" → what kind of growth?
- "facilitate collaboration" → just "help teams work together"
- "optimize outcomes" → which outcomes?
- "maximize value" → what value?

These phrases say nothing. Replace with a specific claim or delete.

## Hedge language

Excessive hedging that adds no value:
- "may or may not" → "may"
- "could potentially" → "could"
- "might possibly" → "might"
- "it appears that" → delete, just state it
- "it seems that" → delete, just state it
- "one could argue" → delete, just argue it
- "some might say" → delete, just say it
- "to a certain extent" → delete
- "generally speaking" → delete

Be direct. If you're uncertain, state the uncertainty concretely: "This hasn't been tested with >10K rows" is useful. "This could potentially have issues" is not.

## Redundant qualifiers

- "completely finished" → "finished"
- "absolutely essential" → "essential"
- "totally unique" / "very unique" → "unique"
- "really important" → "important"
- "past history" → "history"
- "future plans" → "plans"
- "end result" → "result"
- "final outcome" → "outcome"

## Empty intensifiers

Overuse of: "very", "really", "extremely", "incredibly", "quite literally", "actually" (when not contrasting).

These words try to add emphasis and fail. Either the thing is important enough that the reader gets it from context, or you need a better example, not a louder adjective.

## Wordy constructions

| Wordy | Simple |
|-------|--------|
| "in order to" | "to" |
| "due to the fact that" | "because" |
| "at this point in time" | "now" |
| "for the purpose of" | "for" |
| "has the ability to" | "can" |
| "is able to" | "can" |
| "in spite of the fact that" | "although" |
| "take into consideration" | "consider" |
| "make a decision" | "decide" |
| "conduct an investigation" | "investigate" |
| "in the event that" | "if" |
| "prior to" | "before" |
| "subsequent to" | "after" |

### Existential constructions
- "There are many people who..." → "Many people..."
- "It is important to..." → just state the important thing
- "There exists a need for..." → "We need..."

## Structural red flags

### Sentence level
1. Sentences starting with "It is important to note that"
2. Sentences with 3+ hedge words
3. Sentences with both "navigate" and "landscape/complexity"
4. Opening sentences that describe what the text will do instead of doing it

### Paragraph level
1. Opening paragraphs that are pure meta-commentary
2. Paragraphs that restate the title in different words
3. Closing paragraphs that say "in conclusion" then restate without adding insight
4. Every paragraph starting with a transition word

### Document level
1. Buzzword density >5% of unique words
2. Excessive passive voice (>30% of sentences)
3. Generic structure: intro meta-commentary → list of points → conclusion meta-commentary
4. High Flesch-Kincaid grade level without justification

## Cleanup strategies

### Immediate cuts
Remove entirely:
- Meta-commentary about what you will discuss
- Obvious transitions between clearly connected ideas
- Redundant qualifiers
- Empty intensifiers

### Rewrites
- Passive voice → active voice
- Buzzwords → specific terms
- Hedge clusters → one precise statement
- Wordy constructions → simple alternatives

### Structural
- Lead with the point, not a preamble
- Use concrete examples instead of abstract statements
- Vary sentence length and structure
- Break up walls of uniform paragraphs

## When these patterns are NOT slop

- **Academic writing**: hedging is sometimes required by convention
- **Legal documents**: precision requires specific phrasing
- **Long-form content**: transitions are needed between distant ideas
- **Technical writing**: domain jargon serves a real purpose

The issue is *overuse* and *unconscious repetition*, not the existence of any single pattern.
