# Python: Maintainable Patterns

Applies on top of `universal-slop.md`. Assumes Python 3.11+.

## Idioms

- Prefer module-level functions over classes. A class is justified by state + behavior together, not by grouping.
- Dataclasses or plain dicts for data; don't write `__init__` boilerplate by hand.
- Use the stdlib before adding a dependency: `pathlib` not `os.path`, `itertools`, `functools.cache`, `collections.Counter/defaultdict`, `contextlib`.
- F-strings everywhere except logging — use lazy `%` formatting in `logger.*` calls.
- Comprehensions for simple transforms; a for-loop the moment a comprehension needs nesting or a conditional expression inside a conditional.
- Type hints on public function signatures. Skip obvious local annotations (`count: int = 0` is noise).
- `match` only for genuine structural matching; if/elif for 2–3 flat cases.

## Imports

- Match the project's existing import style.
- No imports inside functions except to break a real circular import or defer a genuinely heavy optional dependency — and say why in a one-line comment.
- Don't import `typing.List/Dict/Optional` — use `list`, `dict`, `X | None`.

## Error handling

- Catch the specific exception at the call that raises it, not around the function body.
- `raise ... from e` when translating exceptions, so the chain survives.
- Custom exception classes only when callers need to catch them distinctly. One module-level `class AppError(Exception)` hierarchy with six subclasses nobody catches separately is slop.
- Never `except Exception` outside a top-level boundary (request handler, worker loop, CLI main).

## FastAPI

- Route functions stay thin but don't require a service layer by default. A route that does query → transform → return in 15 lines is fine as-is. Extract a function when logic is reused or the route stops fitting on a screen.
- Pydantic models at the boundary do the validation — don't re-validate inside.
- One Pydantic model per actual shape. Don't create `UserCreate`, `UserUpdate`, `UserResponse`, `UserInDB`, `UserBase` ahead of need; add a model when two endpoints genuinely diverge.
- `Depends()` for real cross-cutting needs (db session, auth). Not for wrapping plain functions to look architectural.
- Don't write custom middleware for things a dependency or an exception handler does.
- Return Pydantic models or dicts directly; don't hand-build `JSONResponse` unless setting status/headers.
- `HTTPException` raised at the point of failure beats error-code plumbing through return values.

## Async

- `async def` only when the function awaits something. Async-colored functions that never await are slop.
- Don't sprinkle `asyncio.gather` over two awaits that take milliseconds; gather when there's measurable concurrent I/O.
- No `asyncio.sleep` retry loops hand-rolled inside business logic — if retries are genuinely needed, use the project's existing mechanism (tenacity, httpx transport retries) or one small dedicated function.

## Testing (when asked to write tests)

- pytest, plain functions, no test classes unless the project uses them.
- Test behavior through the public interface; don't mock internals of the module under test.
- A few well-chosen cases beat parametrized matrices of trivial inputs.
- No `setUp` ceremony for data a literal can express inline.

## Project hygiene

- Respect existing tooling: if there's a `ruff.toml`/`pyproject.toml` lint config, generated code must pass it.
- Don't add `requirements.txt` entries for stdlib-replaceable packages (`requests` when `httpx` is already a dep, `python-dotenv` when config is already handled).
- New module only when an existing one would exceed a clear single responsibility — not per-class, not per-function.
