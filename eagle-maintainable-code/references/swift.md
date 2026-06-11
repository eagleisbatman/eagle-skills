# Swift: Maintainable Patterns

Applies on top of `universal-slop.md`. Covers Swift 5.9+/6, SwiftUI, AppKit/UIKit, macOS menu-bar apps.

## Idioms

- Value types first: structs and enums by default; classes only for reference semantics, ObjC interop, or framework requirements (NSObject subclasses, delegates).
- `guard let` for early exit; avoid pyramid `if let` nesting.
- Don't force-unwrap (`!`) except for programmer-error invariants (IBOutlets, resources bundled with the app) — and those deserve no comment, they're idiomatic.
- Enums with associated values over parallel optionals (`case loaded(Data)` / `case failed(Error)` beats `var data: Data?; var error: Error?`).
- Extensions to organize, not to fragment: one extension per protocol conformance is idiomatic; ten tiny extensions in one file is noise.
- Trailing closures, `map`/`filter`/`compactMap` for simple transforms; a for-loop once closures nest.

## Error handling

- `throws` propagates by default. `do/catch` only where you can present, recover, or translate the error.
- `try?` only when failure genuinely means "absence" (cache miss). Never `try?` to silence an error you should surface.
- No custom `Error` enum with twelve cases when callers only branch on two. Start with the cases callers actually handle.

## Concurrency

- async/await and actors over DispatchQueue/completion handlers in new code — unless the surrounding file is callback-based; match it or migrate it, don't mix.
- `@MainActor` on the type or function that touches UI, not `DispatchQueue.main.async` sprinkled at call sites.
- One actor for genuinely shared mutable state; don't actor-ize stateless helpers.
- `Task { }` fire-and-forget needs a reason; prefer structured concurrency (`async let`, task groups) so cancellation works.
- Don't add locks/queues to state already isolated by an actor or main-actor confinement.

## SwiftUI

- Views are cheap structs — many small views beat one 300-line `body`, but split by responsibility, not arbitrarily.
- `@State` for view-local, `@Binding` to share down, `@Observable` model objects for app state. Don't build a Redux-style store for a three-screen app.
- Derive in `body`; don't mirror derived values into extra `@State` and sync with `onChange`.
- No view models by reflex. SwiftUI views holding simple logic directly are fine; introduce an `@Observable` model when logic outgrows the view or needs testing.
- Modifiers in conventional order (content → layout → style → behavior); no `AnyView` unless type erasure is genuinely forced.

## AppKit / menu-bar specifics

- `NSStatusItem` and friends live in one place (an app delegate or a dedicated controller), not scattered.
- Weak delegates, invalidate timers/observers in deinit — but don't write defensive `[weak self]` in every closure; only where a retain cycle actually forms (stored closures, long-lived tasks).

## Project hygiene

- Match the project's formatting (SwiftFormat/SwiftLint config if present).
- No new SPM dependencies for things Foundation does (`URLSession`, `JSONDecoder`, `FileManager`, `OSLog`).
- `OSLog`/`Logger` over `print` in app code; `print` is fine in scripts.
- One type per file when types are substantial; small related types (an enum + its struct) can share a file. Don't generate five 12-line files.
