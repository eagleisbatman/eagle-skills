# Eagle Anti-Slop

Detect and eliminate AI-generated slop in code, text, and design.

## What it does

AI-generated content has a recognizable smell: over-abstracted code, hedge-heavy prose, gradient-drenched design. This skill spots and fixes those patterns so output reads like it was written by a senior engineer, not a language model.

## Command

```
/eagle-anti-slop
```

Also triggers on: "slop", "anti-slop", "clean up AI code", "review for slop", "detect slop", "over-abstracted", "too many comments"

## What it catches

| Domain | Patterns |
|--------|----------|
| **Code** | Wrapper types without value, single-case error enums, happy-path logging, "what" comments, defensive checks for impossible states, unnecessary abstractions |
| **Text** | "Delve into", "navigate the complexities", meta-commentary, hedge clusters, buzzword density, wordy constructions |
| **Design** | AI startup gradients, glassmorphism everywhere, generic stock photos, center-alignment abuse, card overuse, "Empower Your Business" copy |

## 10 core principles

1. No wrapper types that add indirection without value
2. No defensive code for impossible states
3. No single-case error enums
4. No logging that restates the code
5. No comments that describe what the code does
6. Inline short helpers called once
7. Flat over nested
8. Fewer files over more files
9. Standard library first
10. Test behavior, not implementation

## Bundled scripts

```bash
# Scan a file and get a slop score (0-100)
python eagle-anti-slop/scripts/detect_slop.py myfile.txt

# Preview cleanup
python eagle-anti-slop/scripts/clean_slop.py myfile.txt

# Apply cleanup
python eagle-anti-slop/scripts/clean_slop.py myfile.txt --save

# Aggressive mode (removes transition words too)
python eagle-anti-slop/scripts/clean_slop.py myfile.txt --save --aggressive
```

## How it works

For code: 4-pass review — structure, naming/comments, implementation, language-specific idioms. For text: pattern scoring + rewrite. For design: audit against visual/UX antipattern catalog.
