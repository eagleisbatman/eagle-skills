# TypeScript / JavaScript: Maintainable Patterns

Applies on top of `universal-slop.md`. Covers Node, React, and general TS.

## Types

- Let inference work. Annotate function signatures and exported values; don't annotate locals the compiler already knows (`const count: number = items.length` is noise).
- `interface` or `type` per project convention — don't mix.
- One type per real shape. Don't pre-generate `CreateX`, `UpdateX`, `XResponse`, `PartialX` variants — derive with `Pick`/`Omit`/`Partial` when the second shape actually appears.
- No `any`. If genuinely unknown, `unknown` + narrow. If escaping a third-party typing hole, one `as` with a one-line comment.
- Don't build generic types with three type parameters for a function called from one place.
- Enums: prefer union string literals (`type Status = "active" | "archived"`) unless the project uses enums.

## Functions and modules

- Plain functions over classes. A TS class is justified by long-lived state, not namespacing.
- No barrel files (`index.ts` re-exporting everything) unless the project already uses them.
- No `lib/utils.ts` dumping ground — see universal rule 8.
- Default exports vs named: follow the project; if greenfield, named exports.

## Error handling

- `try/catch` only around the specific awaited call that can fail, only when you can handle it. Otherwise let it propagate to the framework boundary.
- No `catch (e) { console.error(e); }` then continuing as if nothing happened.
- Don't wrap everything in Result/Either types unless the project already uses that style.

## Async

- No `.then()` chains in async functions — use await.
- `Promise.all` for genuinely independent I/O; not for two sequential operations where the second needs the first.
- Don't mark functions `async` that never await.

## React

- Components are functions. Keep them small by extracting when a section has its own state or is reused — not by line count alone.
- State: `useState` for local, lift only when actually shared. Don't reach for context/reducer/store for two components passing one prop.
- `useEffect` is a last resort for synchronizing with external systems. Deriving state in an effect (`useEffect(() => setFullName(first + last))`) is slop — compute during render.
- No `useCallback`/`useMemo` by default. Add them when a measured re-render problem exists or a dependency identity genuinely matters. Memoization wrapping every function is noise that hides the one that matters.
- Don't create a custom hook for logic used in one component. Extract on second use.
- Props: destructure in the signature, take what's used. No `props: any`, no spreading mystery objects through layers.
- Keys are stable IDs, never array index for dynamic lists.
- Styling/markup follows the project's existing system (Tailwind, CSS modules, styled-components) — never introduce a second one.

## Node / API

- Route handlers can hold the logic if it fits on a screen. Controller→service→repository layering for a 4-endpoint API is over-engineering; introduce layers when duplication or testing pain demands them.
- Validate at the boundary with whatever the project uses (zod, etc.) and trust types internally.
- Use the platform: `fetch`, `URL`, `crypto`, `structuredClone`, `node:fs/promises` — before adding axios/lodash/uuid.

## Project hygiene

- Generated code must pass the project's existing ESLint/Biome/Prettier config — read it before writing.
- Match the project's module system (ESM vs CJS), path aliases, and tsconfig strictness. Don't fight it, don't loosen it.
- No new dependencies without checking package.json for an existing one that does the job.
