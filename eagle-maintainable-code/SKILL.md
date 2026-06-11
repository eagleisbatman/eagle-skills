---
name: eagle-maintainable-code
description: Write code the way an experienced human engineer writes it — minimal, direct, first-principles, no AI slop, no over-engineering. Use this skill for EVERY code generation, refactoring, or code review task, in any language. Trigger especially when the user says "maintainable", "clean", "simple", "no slop", "don't over-engineer", "production code", "like a human wrote it", or complains that generated code is bloated, over-abstracted, over-commented, or defensive. Also use when writing new modules, functions, scripts, API endpoints, or components from scratch.
---

# Maintainable Code

Generated code has a recognizable fingerprint: narrating comments, defensive try/except wrapping, speculative abstraction, config options nobody asked for, and a "Manager" class for everything. This skill removes that fingerprint. The output should read like a senior engineer wrote it under code review pressure: every line earns its place.

## Workflow

1. **Detect the stack.** Look at the repo before writing anything: lockfiles, existing imports, framework conventions, lint config, how existing code in the project is structured. Match what's there. Never introduce a new library, pattern, or layer when the project already has one for that job.
2. **Load the rules.** The bans and principles in this file plus `references/universal-slop.md` are language-agnostic — they are the skill, and they apply to every stack: Go, Rust, Kotlin, Java, Ruby, PHP, Dart, C#, SQL, shell, anything. Read `universal-slop.md` on the first code task in a session. Then, if a language-specific refinement exists, read it too:
   - Python / FastAPI → `references/python.md`
   - TypeScript / JavaScript / React / Node → `references/typescript.md`
   - Swift / SwiftUI / macOS / iOS → `references/swift.md`
   - Any other stack → `references/any-stack.md` (a protocol for deriving that language's idioms from the repo itself)
3. **Think before coding.** State assumptions explicitly; if uncertain, ask. If multiple interpretations of the request exist, present them — don't pick one silently. If a simpler approach exists than the one requested, say so and push back. Don't hide confusion behind plausible-looking code.
4. **State the simplest design in one or two sentences** before writing it (to yourself, or to the user if the task is non-trivial). If the design sentence contains the words "abstract", "flexible", "extensible", or "generic", rewrite it.
5. **Write the test first, then the code.** For any behavior change, follow the Test-Driven loop below: failing test → minimum code to pass → refactor. Apply the rules below while writing.
6. **Verify with a real check — this is a gate, not a step.** Run the relevant test suite plus the project's build/lint/type checks. Show the evidence (test output, exit code), don't assert success. Work that hasn't passed a check isn't done. If no check can exist for the change, state explicitly how the user should verify.
7. **Self-review pass.** Before presenting, reread the diff and delete: comments that restate code, error handling for impossible states, parameters with only one call-site value, and any function used exactly once that doesn't clarify the call site. In agentic environments with subagents, delegate this review to a fresh subagent with no conversation history — a cold reviewer can't rationalize its own design decisions.

## First Principles

**Solve the problem in front of you.** Not the problem you imagine the user will have next quarter. Requirements that don't exist yet get code written when they exist. The cheapest code to maintain is code that was never written.

**The rule of three.** Don't abstract until the third occurrence. Two similar blocks of code are cheaper to maintain than one premature abstraction with two config flags. Duplication is far cheaper than the wrong abstraction.

**Surgical changes.** When editing existing code, every changed line should trace directly back to the request. Don't reformat untouched code, don't rename things outside scope, don't refactor what isn't broken, don't "improve" adjacent code while you're in there. Match the existing style even where you'd choose differently. Clean up only your own mess: remove imports, variables, and functions that YOUR changes orphaned; if you notice pre-existing dead code, mention it — don't delete it unless asked.

**Errors fail loudly at the source — fix root causes, not symptoms.** Don't catch an exception just to log it and continue with bad state. Don't return `None`/`null`/empty-list as a silent fallback. Never suppress an error to make a build or test pass — find why it fires. A crash with a clear stack trace is more maintainable than a system limping along with corrupted assumptions.

**Locality over indirection.** A reader should understand a function by reading it top to bottom. Every layer of indirection (interface, factory, callback, event) is a tax on the reader. Pay it only when it buys something concrete today.

**Boring beats clever.** A for-loop beats a triple-nested comprehension. An if/else beats a dispatch table with two entries. Code is read 10x more than it's written; optimize for the reader at 11pm during an incident.

## Universal Bans (all languages)

These patterns mark code as machine-generated. Never produce them:

### Comments
- No comments that restate the code (`# increment counter`, `// loop over users`).
- No section-divider comments (`# ===== HELPERS =====`).
- No changelog comments (`# Updated to handle edge case`, `// Fixed bug`). Git holds history.
- No TODO comments for things you could just do now.
- Comments explain WHY, never WHAT. Target: most functions have zero comments. A non-obvious algorithm, a workaround for an upstream bug, or a surprising business rule deserve one. Nothing else does.

### Structure
- No single-implementation interfaces or abstract base classes "for testability" or "for the future".
- No `Manager`, `Handler`, `Processor`, `Helper`, `Util`, `Service` classes that are just namespaces for functions. Use module-level functions.
- No wrapper functions that only call another function with the same arguments.
- No getters/setters that do nothing but get and set, in languages where plain attributes work.
- No config parameters, environment variables, or function arguments with exactly one value ever passed. Hard-code it; extract it when a second value appears.
- No "plugin architecture", registry, or dynamic dispatch for a fixed, known set of 2–3 cases. Use if/elif.
- No copy-pasting a code block and tweaking it. If you're about to paste a near-duplicate, either it's the third occurrence (extract a function) or the second (small duplication is fine, but write it fresh and minimal, don't clone the slop of the first).
- Functions take the few arguments they need, not an options object designed for hypothetical callers.

### Error handling
- No blanket try/except (or try/catch) around whole function bodies.
- Catch specific exceptions, only where you can actually do something about them.
- No `except Exception: pass` or equivalent — ever.
- No validating conditions the type system or caller already guarantees.
- No fallback values that mask failure (`return []` on error when caller expects data).

### Naming and prose
- Names are short and concrete: `users`, not `user_data_list`; `retry()`, not `handle_retry_logic()`.
- No emoji in code, comments, log messages, or commit messages.
- No docstring/JSDoc on private helpers whose name already says what they do. Document public API surfaces and anything with non-obvious behavior; skip the rest.
- Log messages state facts for operators (`"payment webhook rejected: bad signature"`), not narration (`"Starting to process the payment now..."`).

### Output discipline
- Don't print/log success confirmations after every step.
- Don't add `if __name__ == "__main__"` demo blocks unless the file is meant to be run.
- Don't generate example usage, sample data, or test scaffolding unless asked.

## Test-Driven by Default

Code is not done when it's written; it's done when a test proves it works. Default to this loop for any behavior change:

1. **Red.** Write the test first — a failing test that encodes the requirement. Run it and confirm it fails for the right reason. A test that passes before the fix exists tests nothing.
2. **Green.** Write the minimum code that makes it pass. Run the test.
3. **Refactor.** Clean up with the test as a safety net. Run the full relevant suite, not just the new test, to catch regressions.

Transform vague tasks into this loop before starting:

- "Add validation" → write tests for the invalid inputs first, then make them pass.
- "Fix the bug" → write a failing test that reproduces it, then make it pass. The bug fix without the reproducing test will regress.
- "Refactor X" → confirm tests pass before AND after; the behavioral diff should be zero.
- "Add an endpoint/feature" → write the test that calls it the way a real client will, then implement.

**Test the product, not just the code.** Unit tests on internals can all pass while the product is broken. Prefer tests that exercise behavior the way it's actually used: call the API endpoint, run the CLI command, invoke the public function — through the real entry point. For UI changes, run the app or take a screenshot and compare; "it compiles" is not verification.

**Definition of done:** the check ran, it passed, and the evidence (test output, exit code, screenshot) is in the response. Never claim something works based on reading the code. If the project has no test infrastructure and setting it up is out of scope, say so explicitly and state exactly how the user should verify — don't silently skip verification.

**Tests are code too — slop rules apply.** Test behavior through public interfaces; don't mock the internals of the module under test. A few well-chosen cases (happy path, the edge that motivated the change, the failure mode) beat parametrized matrices of trivial inputs. Use the project's existing test framework and conventions, never introduce a second one. A 200-line test file for a 10-line function is its own kind of over-engineering.

Prefer the project's existing verification commands (its test runner, lint config, build command) over inventing new checks.

**Rewrite over patch.** If the first implementation comes out mediocre — patched-together, fighting itself — don't layer fixes on it. Scrap it and reimplement cleanly using what was learned, with the tests you already wrote as the safety net. The second draft written with full knowledge of the problem is usually half the size of the first draft plus its patches.

## Sizing Heuristics

- A function that fits on one screen (~40 lines) rarely needs splitting. Splitting a 30-line function into six 5-line functions makes it harder to read, not easier.
- A new file needs a reason. Default to adding to an existing module until it has a clear second responsibility.
- If the task is "add an endpoint", the diff is usually one route function and maybe one query. If your plan involves a new service layer, DTO, mapper, and exception hierarchy, the plan is wrong.

## When Complexity IS Justified

This skill is anti-over-engineering, not anti-engineering. Reach for structure when the problem demands it today:

- A real second implementation exists → an interface is now fine.
- Concurrency, retries with backoff, idempotency for payment/external-API code → yes, build it properly.
- A function genuinely has 5 responsibilities → split it.
- Hot path with measured (not imagined) performance problem → optimize it, with a comment citing the measurement.

The test is always: does this complexity solve a problem that exists right now, in this codebase, with evidence? If yes, build it well. If the justification starts with "in case" or "someday", delete it.

## Self-Review Checklist

Run before presenting any code:

1. Could I delete any function/class and inline it without loss? → do it.
2. Does any comment restate the line below it? → delete it.
3. Does any try/catch swallow an error or wrap more than the failing call? → narrow or remove it.
4. Does any parameter, flag, or config key have only one value in the entire codebase? → hard-code it.
5. Is there any code that exists only for a future that hasn't arrived? → delete it.
6. Does the diff touch lines unrelated to the task? → revert them.
7. Did I run the project's check (tests/lint/build) and show the output? → if not, run it now.
8. Does every behavior change have a test that fails without it? → if not, write it.
9. Would a senior engineer reviewing this ask "why is this here?" about anything? → fix it before they ask.

## Sources

Distilled from: Andrej Karpathy's observations on LLM coding pitfalls (think before coding, surgical changes, simplicity first, goal-driven execution); Anthropic's Claude Code best practices (verify with a runnable check, evidence over assertion, root causes over symptom suppression, follow existing codebase patterns); Boris Cherny's workflow (plan before code, code-simplifier pass, rewrite mediocre fixes from scratch); and community anti-slop skills (cold subagent review, lint-after-edit gates).
