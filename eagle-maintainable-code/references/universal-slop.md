# Universal AI Slop Patterns — Before/After

Language-agnostic examples of the generated-code fingerprint and the human fix. Read alongside the language-specific reference.

## 1. Narrating comments

**Slop:**
```python
# Initialize the results list
results = []
# Loop through each item in the data
for item in data:
    # Check if the item is valid
    if item.valid:
        # Add the item to results
        results.append(item)
```

**Human:**
```python
results = [item for item in data if item.valid]
```

## 2. Defensive wrapping

**Slop:**
```python
def get_user(user_id):
    try:
        user = db.query(User).filter_by(id=user_id).first()
        if user is None:
            logger.warning(f"User {user_id} not found")
            return None
        return user
    except Exception as e:
        logger.error(f"Error fetching user: {e}")
        return None
```

**Human:**
```python
def get_user(user_id):
    return db.query(User).filter_by(id=user_id).one()
```
Let the DB error propagate. The caller decides what "not found" means; a generic `return None` forces every caller to handle two failure modes (None and exception) instead of one.

## 3. Speculative abstraction

**Slop:**
```python
class NotificationStrategy(ABC):
    @abstractmethod
    def send(self, message: str) -> None: ...

class EmailNotificationStrategy(NotificationStrategy):
    def send(self, message: str) -> None:
        smtp_send(message)

class NotificationManager:
    def __init__(self, strategy: NotificationStrategy):
        self._strategy = strategy
    def notify(self, message: str) -> None:
        self._strategy.send(message)
```

**Human:**
```python
def send_email(message: str) -> None:
    smtp_send(message)
```
There is one notification channel. When SMS arrives, refactor then — it'll take five minutes and you'll design the abstraction around two real cases instead of guesses.

## 4. Config for constants

**Slop:**
```python
MAX_RETRIES = int(os.getenv("MAX_RETRIES", "3"))
RETRY_DELAY_SECONDS = float(os.getenv("RETRY_DELAY_SECONDS", "1.0"))
ENABLE_RETRY_BACKOFF = os.getenv("ENABLE_RETRY_BACKOFF", "true").lower() == "true"
```

**Human:**
```python
MAX_RETRIES = 3
```
Nobody has ever set these env vars. Each one is a code path that's never been tested.

## 5. The options object

**Slop:**
```typescript
interface FetchUsersOptions {
  includeInactive?: boolean;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
  limit?: number;
  offset?: number;
  fields?: string[];
}
function fetchUsers(options: FetchUsersOptions = {}) { ... }
```
(when the only call site is `fetchUsers({ limit: 50 })`)

**Human:**
```typescript
function fetchUsers(limit: number) { ... }
```

## 6. Success narration

**Slop:**
```
logger.info("Starting data processing...")
logger.info("Data loaded successfully!")
logger.info("Processing complete! ✅")
logger.info(f"Successfully processed {len(items)} items! 🎉")
```

**Human:**
```
logger.info("processed %d items in %.1fs", len(items), elapsed)
```
One log line, with the facts an operator needs. No emoji, no exclamation marks, no "successfully" (if it logged, it succeeded).

## 7. Validation theater

**Slop:**
```python
def calculate_total(items: list[LineItem]) -> Decimal:
    if items is None:
        raise ValueError("items cannot be None")
    if not isinstance(items, list):
        raise TypeError("items must be a list")
    for item in items:
        if not isinstance(item, LineItem):
            raise TypeError("each item must be a LineItem")
    ...
```

**Human:**
```python
def calculate_total(items: list[LineItem]) -> Decimal:
    return sum(i.price * i.qty for i in items)
```
The type hint is the contract. Re-checking it at runtime in internal code triples the function for zero protection. Validate at trust boundaries (API input, file parsing, user input) — nowhere else.

## 8. The everything-helper

**Slop:** a `utils.py` / `helpers.ts` accumulating `format_date`, `safe_get`, `chunk_list`, `retry_wrapper`, `deep_merge` — each used once, half reimplementing stdlib.

**Human:** check the stdlib/language first (`itertools.batched`, `dict.get`, `structuredClone`). If genuinely needed once, define it next to its one caller. A shared utils module is earned by the third caller.

## 9. Dead flexibility

**Slop:**
```python
def export_report(data, format="csv"):
    if format == "csv":
        return to_csv(data)
    elif format == "json":
        return to_json(data)
    elif format == "xml":
        raise NotImplementedError("XML support coming soon")
```
(every caller passes csv)

**Human:**
```python
def export_report_csv(data):
    return to_csv(data)
```

## 10. Restating docstrings

**Slop:**
```python
def get_user_by_id(user_id: int) -> User:
    """
    Get a user by their ID.

    Args:
        user_id: The ID of the user to get.

    Returns:
        User: The user with the given ID.
    """
```

**Human:** no docstring. The signature already says all of this. Write docstrings only when they add information the signature can't carry: units, side effects, raised exceptions callers must handle, non-obvious behavior.
