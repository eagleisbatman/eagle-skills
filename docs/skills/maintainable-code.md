# Eagle Maintainable Code

Write code the way an experienced human engineer writes it — minimal, direct, first-principles, no AI slop, no over-engineering.

## What it does

Generated code has a recognizable fingerprint: narrating comments, defensive try/except wrapping, speculative abstraction, config options nobody asked for, and a "Manager" class for everything. This skill removes that fingerprint. Output reads like a senior engineer wrote it under code review pressure: every line earns its place.

## Command

```
/eagle-maintainable-code
```

Also triggers on: "maintainable", "clean code", "keep it simple", "don't over-engineer", "production code", "like a human wrote it", or complaints that generated code is bloated, over-abstracted, over-commented, or defensive.

## Workflow

1. **Detect the stack** — read lockfiles, imports, lint config, and existing conventions before writing anything
2. **Load the rules** — universal bans always apply; language refinements for Python, TypeScript, and Swift load on demand
3. **Think before coding** — state assumptions, surface alternative interpretations, push back when a simpler approach exists
4. **State the simplest design** in one or two sentences before writing it
5. **Test-driven loop** — failing test → minimum code to pass → refactor
6. **Verify with a real check** — run tests/lint/build and show the evidence; this is a gate, not a step
7. **Self-review pass** — delete restating comments, impossible-state handling, single-value parameters, and one-call indirection

## First principles

- Solve the problem in front of you, not next quarter's
- The rule of three — don't abstract until the third occurrence
- Surgical changes — every changed line traces back to the request
- Errors fail loudly at the source — fix root causes, not symptoms
- Locality over indirection
- Boring beats clever

## Reference files

| File | Covers |
|------|--------|
| `references/universal-slop.md` | Language-agnostic slop catalog — read on the first code task in a session |
| `references/python.md` | Python / FastAPI idioms |
| `references/typescript.md` | TypeScript / JavaScript / React / Node idioms |
| `references/swift.md` | Swift / SwiftUI / macOS / iOS idioms |
| `references/any-stack.md` | Protocol for deriving any other language's idioms from the repo itself |

## Example

```
Add a retry helper to this API client — keep it simple, no over-engineering
```

## Related

- [Anti-Slop](anti-slop.md) — detects and removes slop in existing code, text, and design; Maintainable Code prevents it at generation time
- [Feature Flow](feature-flow.md) — the structured dev workflow this skill slots into
