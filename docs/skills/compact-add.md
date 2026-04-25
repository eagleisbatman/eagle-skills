# Eagle Compact Add

Add new rules to the compact token-saving hook.

## What it does

The [compact hook system](../compact-hook.md) rewrites verbose Bash commands using regex rules to save context window tokens. This skill helps you design, validate, and add new rules to `compact-rules.json`.

## Command

```
/eagle-compact-add
```

Also triggers on: "add compact rules", "compact-add", "this command is too verbose", "compact this command"

## Workflow

1. You tell Claude which command is too verbose (or it spots one during your session)
2. Claude proposes a rule:
   - **Flag rule** if truncation flags exist (`-n`, `--limit`, `--max-count`)
   - **Pipe rule** if output needs filtering (test results, build logs, lint)
3. Validates the regex pattern against sample commands
4. Shows the proposed rule for your confirmation
5. Appends the confirmed rule to `compact-rules.json`

## Output

```
Proposed rule:
  terraform plan → pipe:generic  pattern: ^terraform plan\b

Confirm? [y/N]
```

## Example

```
You: That terraform plan output was way too long, compact it
Claude: [proposes a pipe rule with generic filter, validates, asks to confirm]
```
