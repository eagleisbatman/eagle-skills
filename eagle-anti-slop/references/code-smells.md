---
name: code-smells
description: Full catalog of AI slop patterns in code. Naming, comments, structure, implementation, and documentation antipatterns across Swift, Python, TypeScript, and Java.
---

# Code Slop Patterns

## Naming

### Generic names
`data`, `result`, `temp`, `value`, `item`, `thing`, `obj`, `info` — these tell you nothing.

| Generic | Better |
|---------|--------|
| `data` | `userProfile`, `rawPayload`, `csvRows` |
| `result` | `parsedDocument`, `validationError`, `sortedItems` |
| `temp` | `formattedDate`, `normalizedInput`, `previousValue` |
| `item` | `transaction`, `notification`, `menuEntry` |

### Over-verbose names
`getUserDataFromDatabaseByUserIdAndReturnResult()` — the signature and context provide enough info. Call it `getUser(userId)`.

### Generic suffixes
`Helper`, `Manager`, `Handler`, `Processor`, `Service` — these words mean "I couldn't think of a name." A `UserManager` that only has `getUser()` is just `getUser()`.

## Comments

### Restating code
```python
# Bad — every line is narrated
counter += 1  # Increment the counter
user = User()  # Create a user
return result  # Return the result
for item in items:  # Loop through the items
    process(item)  # Process each item
```

Delete all of these. The code says what the code does.

### Generic TODOs
```python
# Bad
# TODO: Implement this function
# TODO: Add error handling
# TODO: Refactor this

# Good — says WHO, WHAT specifically, WHY
# TODO(gautam): Handle 429 rate limit from Twilio — currently retries forever
```

### Section banners
```python
# Bad
########################################
# INITIALIZATION
########################################
```
Use functions to organize code. If you need a comment to show structure, your structure is wrong.

### Over-documented internals
```python
# Bad — 30-line docstring on a private one-liner
def _format_date(date_obj):
    """Format a date object into a string.
    
    This function takes a date object and formats it according to
    ISO 8601 standards. It is used internally by the DateProcessor
    class to ensure consistent date formatting across the application.
    
    Args:
        date_obj (datetime): A datetime object representing the date...
    [25 more lines]
    """
    return date_obj.isoformat()

# Good
def _format_date(date_obj):
    return date_obj.isoformat()
```

Public library APIs deserve docs. Private helpers don't.

## Structure

### Unnecessary abstraction layers
```python
# Bad — factory that produces a manager that wraps a repository
class UserManagerFactory:
    def create_user_manager(self):
        return UserManager()

class UserManager:
    def get_user_repository(self):
        return UserRepository()

class UserRepository:
    def get_user(self, user_id):
        return db.query(User).filter(User.id == user_id).first()

# Good
def get_user(user_id):
    return db.query(User).filter(User.id == user_id).first()
```

Don't add abstraction layers until you need them.

### Design patterns for their own sake
Not everything needs a Factory, Singleton, Observer, Strategy, or Adapter. Use patterns when they solve real problems, not because they're in the textbook.

### Protocols / interfaces with one conformer
```swift
// Bad — protocol exists only for one class
protocol AudioRecording {
    func start() throws
    func stop() -> Data
}
class AudioRecorder: AudioRecording { ... }

// Good — just use the class
class AudioRecorder {
    func start() throws { ... }
    func stop() -> Data { ... }
}
```

Extract a protocol when a second conformer appears, not before.

### Error enums nobody switches on
```swift
// Bad — 4 cases, every catch site is generic
enum APIError: Error {
    case invalidURL
    case httpError(statusCode: Int, body: String)
    case decodingError(Error)
    case networkError(Error)
}
// ...
catch { showError("Upload failed") }  // never inspects the case

// Good — simple struct for the one error worth typing
struct HTTPError: Error {
    let statusCode: Int
    let body: String
}
// Let URLSession and JSONDecoder errors propagate naturally
```

### Enum-as-namespace with one static member
```swift
// Bad
enum MessageDecoding {
    static let decoder: JSONDecoder = { ... }()
}

// Good
let messageDecoder: JSONDecoder = { ... }()
```

## Implementation

### Wrapping errors for no reason
```swift
// Bad — wraps every error in a custom type
do {
    (data, response) = try await session.data(for: request)
} catch {
    throw APIError.networkError(error)
}
// ...
do {
    return try decoder.decode(T.self, from: data)
} catch {
    throw APIError.decodingError(error)
}

// Good — let errors propagate
let (data, response) = try await session.data(for: request)
return try decoder.decode(T.self, from: data)
```

Only wrap when the caller actually needs to distinguish error types.

### Defensive code for impossible states
```python
# Bad — result from your own query two lines up
result = client.table("x").select("*").eq("id", id).maybe_single().execute()
# Defensive: maybe_single().execute() returns APIResponse (never None
# itself), but guard against future postgrest-py changes.
if result is None:
    return None
return result.data

# Good — trust the library contract
result = client.table("x").select("*").eq("id", id).maybe_single().execute()
return result.data
```

### Happy-path logging
```python
# Bad — logging things that always succeed
logger.info("Starting recording")
recorder.start()
logger.info("Recording started successfully")
logger.info("Audio session resumed after interruption")
logger.info("dev session created: session=%s", session_id)

# Good — log only surprising outcomes
try:
    recorder.start()
except AudioError:
    logger.error("Recording failed: %s", error)
```

### Config objects for 1-2 values
```swift
// Bad
struct AudioRecorderConfig {
    let sampleRate: Double
    let channels: Int
}
class AudioRecorder {
    init(config: AudioRecorderConfig) { ... }
}

// Good — just pass the values
class AudioRecorder {
    init(sampleRate: Double = 16_000, channels: Int = 1) { ... }
}
```

## Language-specific

### Swift
- `@preconcurrency import` — only needed for Apple frameworks with incomplete Sendable annotations (AVFoundation, UIKit). Don't cargo-cult it on Foundation.
- Single-case enums: `enum FooError: Error { case onlyOneCase }` → `struct FooError: Error {}`
- Namespace enums: `enum Foo { static let bar }` → module-level `let bar`
- `/// Docstring` on every private/internal function — stop. Only document public API and non-obvious behavior.
- `os.Logger` on every file when 80% of log lines are happy-path info.

### Python
- `logger = logging.getLogger(__name__)` in every file, used once for an info log → remove.
- `except Exception: pass` → either handle or propagate.
- `# type: ignore` blanket suppressions → fix the types.
- `from module import *` → import what you need.
- `def f(items=[])` → `def f(items=None)` then `items = items or []`.
- f-string SQL: `f"SELECT * FROM {table}"` → parameterized queries.

### TypeScript / JavaScript
- `any` and `as any` → type it properly or use `unknown`.
- `console.log` in production → remove or use a logger.
- Empty catch blocks → handle or rethrow.
- `.then()` without `.catch()` → add error handling or use async/await.
- Functions over 80 lines → extract.

### Java
- Getter/setter boilerplate for simple data holders → use records (Java 16+).
- Single-implementation interfaces → use the class directly.
- `Object` types → use generics.
- Deep inheritance hierarchies → prefer composition.

## Detection signals

### High confidence (almost always slop)
1. Variable named `result` holding different types across the file
2. Functions with generic verbs: `handleData`, `processInfo`, `manageItems`
3. Comments that explain syntax rather than intent
4. Every function has a docstring, even 3-line private helpers
5. Consistent over-engineering across the whole codebase

### Medium confidence (often slop, check context)
1. Very long names encoding the full call context
2. Null-checks on values that the type system guarantees non-null
3. Uniform structure across all functions (same patterns everywhere)
4. Empty or minimal implementations with "TODO" comments

## When patterns are NOT slop

- Generic names in tiny scopes: `i`, `x`, `acc` in a 3-line lambda is fine.
- Verbose names in public APIs: better too clear than too cryptic.
- Defensive programming at system boundaries: user input, network, file I/O.
- Detailed docstrings on public library APIs.
- Design patterns in large codebases where they genuinely reduce complexity.

The key is *intentional engineering* vs *mindless pattern repetition*.
