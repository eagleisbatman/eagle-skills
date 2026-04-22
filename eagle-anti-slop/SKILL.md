---
name: eagle-anti-slop
description: "Detects and eliminates AI-generated slop in code, text, and design. Use this skill whenever the user asks to review code quality, clean up AI-generated content, remove LLM patterns, simplify over-engineered code, or make output feel human-written. Trigger on: 'review for slop', 'too much AI', 'over-engineered', 'simplify this', 'feels like AI wrote this', 'clean up this code', 'make it human', 'remove the slop', 'code quality review', 'LLM smell', 'vibe check', 'anti-slop'. Also trigger proactively when you notice AI-typical patterns in code or text you're writing or reviewing — don't wait for the user to ask."
---

# Eagle Anti-Slop

Detect and kill AI-generated slop across code, text, and design. LLM output has a recognizable smell: over-abstracted, over-commented, over-logged, over-typed. This skill trains you to find it and fix it.

## What is slop?

Slop is the gap between what a senior engineer would write at 2 AM and what an LLM produces. It manifests as:

- **Code**: Wrapper types nobody uses, error enums with one case, logging that restates the code, comments that describe what instead of why, defensive checks for impossible states, abstractions with one consumer.
- **Text**: "Delve into", "it's important to note", meta-commentary about what the document will discuss, hedge stacking, buzzword density.
- **Design**: Purple-pink gradients, glassmorphism everywhere, "Empower your business" headlines, cards-for-everything layouts.

Slop isn't wrong code. It compiles, passes tests, maybe even passes code review. It's *unnecessary* code — weight that slows understanding, maintenance, and iteration without adding safety or capability.

## When to use this skill

- **After writing code** — review your own output before presenting it
- **On user request** — "clean this up", "too much AI", "simplify"
- **During code review** — flag patterns in PRs or existing codebases
- **On text/docs** — clean up AI-generated prose, READMEs, commit messages
- **Proactively** — if you notice yourself producing slop mid-task, stop and fix it

## Core principles

These are not suggestions. They are the bar.

### 1. No wrapper types without proven need
If a function takes a `String`, pass a `String`. Don't invent `SessionIdentifier` until three callers need to distinguish it from other strings and you've been burned by a mixup.

### 2. No defensive code for impossible states
If a value comes from your own code two lines up, don't nil-check it. Trust the type system. Guard at system boundaries (user input, network responses, external APIs). Trust internal code.

### 3. No custom error types with one case
```swift
// Slop
enum AudioError: Error { case converterCreationFailed }

// Human
struct AudioError: Error {}
```
Use stdlib errors or a plain struct until you have 3+ distinct error paths that callers actually switch on.

### 4. No logging that restates the code
```python
# Slop
logger.info("Starting recording")
recorder.start()
logger.info("Recording started successfully")

# Human — log surprising outcomes only
try:
    recorder.start()
except AudioError:
    logger.error("Recording failed: mic unavailable")
```

### 5. No comments that describe what
The code describes what the code does. Comments explain *why* — a workaround, a non-obvious constraint, a business rule invisible in the types. If removing the comment wouldn't confuse a future reader, delete it.

```python
# Slop
# Create a user
user = User()

# Slop
# Loop through items and process each one
for item in items:
    process(item)

# Human — explains a non-obvious constraint
# Resume the continuation here to prevent a leak when stop()
# is called before max duration fires.
continuation.resume()
```

### 6. Inline short helpers
A 3-line private function called once is not an abstraction — it's a scroll tax. Inline it. Extract when you see the same logic in 3+ places.

### 7. Flat over nested
Prefer `guard` + early return over nested `if let` chains. Prefer a single function over a protocol with one conformer. Prefer a module-level `let` over an enum-used-as-namespace with one static property.

### 8. Fewer files over more files
Two related 80-line types in one file is better than two 80-line files with one type each. Only split when a file approaches your size limit or when types serve genuinely different callers.

### 9. Stdlib first
Use `URLSession` before Alamofire. Use `JSONDecoder` before custom parsing. Use `Task {}` before Combine. If the stdlib solution is 5 lines longer but zero dependencies, it wins.

### 10. Test behavior, not implementation
A test that asserts "state == .idle after init" is fine. A test that asserts the mock was called with specific arguments is coupling to implementation. Tests should survive a refactor.

## Code review workflow

When reviewing code for slop, work through this checklist. For each file, ask:

### Pass 1 — Structure (30 seconds per file)
- [ ] Any type/class/enum with one case, one method, or one conformer?
- [ ] Any file that's just a thin wrapper around a stdlib type?
- [ ] Any protocol with exactly one implementation?
- [ ] Any error enum where callers always catch generically?

### Pass 2 — Comments and logging (30 seconds per file)
- [ ] Any comment that restates the next line of code?
- [ ] Any docstring on a private/internal function that just says what it does?
- [ ] Any `logger.info()` on a happy path? (success, start, finish)
- [ ] Any `logger.debug()` that restates the function call?

### Pass 3 — Defensive code (30 seconds per file)
- [ ] Any nil-check on a value that can't be nil?
- [ ] Any guard against an impossible state (checking your own code's output)?
- [ ] Any try/catch that wraps an error just to re-throw a different error type?
- [ ] Any "guard against future changes" comment?

### Pass 4 — Over-engineering (30 seconds per file)
- [ ] Any abstraction layer with only one consumer?
- [ ] Any factory, builder, or manager class for a straightforward operation?
- [ ] Any generic function instantiated with only one type?
- [ ] Any configuration object for 1-2 values that could be parameters?

### Reporting format

For each finding, report:

```
[FILE:LINE] PATTERN — one-line description
  Before: <the sloppy code>
  After:  <the clean version>
```

Group findings by file. Don't suggest; just fix. If the user asked for a review, fix everything and show the diff. If they asked for a report, list findings with before/after.

## Text review workflow

Read `references/text-smells.md` for the full pattern catalog. Quick version:

### Immediate kills (delete on sight)
- "delve into", "dive deep into", "unpack"
- "navigate the complexities", "in today's fast-paced world"
- "it's important to note that", "it's worth noting that"
- "in this article, I will discuss..."
- "let's take a closer look..."

### Simplify (replace with shorter version)
| Slop | Human |
|------|-------|
| "in order to" | "to" |
| "due to the fact that" | "because" |
| "has the ability to" | "can" |
| "leverage" | "use" |
| "utilize" | "use" |
| "facilitate" | "help" / "enable" |

### Structural red flags
- Opening paragraph that describes what the document will cover instead of just covering it
- Every paragraph starts with a transition word
- Closing paragraph that says "in conclusion" then summarizes without new insight
- Excessive hedging: "might possibly perhaps", "could potentially"

## Design review workflow

Read `references/design-smells.md` for the full catalog. Quick version:

### Visual slop
- Purple/pink/cyan mesh gradients (the "AI startup" look)
- Glassmorphism or neumorphism on everything
- Floating 3D shapes without purpose
- Same visual treatment on every element

### Copy slop
- "Empower your business" headlines
- Generic CTAs: "Get Started", "Learn More" without context
- Buzzword-dense descriptions that say nothing specific

### Layout slop
- Everything in cards regardless of content type
- Center-alignment of all text
- Template-driven structure ignoring actual content needs

## Language-specific patterns

### Swift
- `@preconcurrency import` where not needed (only for frameworks with incomplete Sendable annotations)
- `enum FooError: Error { case onlyOneCase }` — use a struct
- `enum Namespace { static let thing }` — use a module-level `let`
- Logger on every service file when most log lines are happy-path
- `/// Docstring` on every function including private helpers

### Python
- `logger = logging.getLogger(__name__)` in every file when only used for one happy-path log
- `except Exception: pass` — either handle it or let it propagate
- `# type: ignore` blanket suppressions
- `import *` — namespace pollution
- Mutable default arguments: `def f(items=[])`
- f-string SQL (injection vector, not just slop)

### TypeScript / JavaScript
- `any` and `as any` casts
- `console.log` left in production code
- Dynamic code execution via `eval` or `Function` constructors
- Empty catch blocks
- `.then()` chains without `.catch()`
- Functions over 80 lines

## Reference files

For comprehensive pattern catalogs, read these as needed:

- **`references/code-smells.md`** — Full code pattern catalog across Swift, Python, TypeScript, Java. Naming, comments, structure, implementation, documentation antipatterns.
- **`references/text-smells.md`** — Natural language patterns. Overused phrases, hedge language, meta-commentary, buzzwords, filler constructions.
- **`references/design-smells.md`** — Visual and UX patterns. Color, typography, layout, component, copy, animation antipatterns.

## The test: would a human write this line?

For every line of code, every sentence of text, every design decision — ask: would a senior practitioner writing this by hand add this? If the answer is "probably not, but it seems thorough," delete it. Thoroughness that adds no value is slop.
