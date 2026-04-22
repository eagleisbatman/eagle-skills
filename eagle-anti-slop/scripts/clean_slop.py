#!/usr/bin/env python3
"""Automatically removes common AI slop patterns from text files."""

import re
import sys
from pathlib import Path


PHRASE_REPLACEMENTS = {
    r"\b(?:delve|dive deep) into\b": "",
    r"\bnavigate the complexit(?:y|ies) of\b": "handle",
    r"\bin the ever-evolving landscape of\b": "in",
    r"\bin today's fast-paced world,?\b": "",
    r"\bin today's digital age,?\b": "",
    r"\bat the end of the day,?\b": "",
    r"\bit's important to note that\b": "",
    r"\bit's worth noting that\b": "",
}

WORDY_REPLACEMENTS = {
    r"\bin order to\b": "to",
    r"\bdue to the fact that\b": "because",
    r"\bat this point in time\b": "now",
    r"\bfor the purpose of\b": "for",
    r"\bhas the ability to\b": "can",
    r"\bis able to\b": "can",
    r"\bin spite of the fact that\b": "although",
    r"\btake into consideration\b": "consider",
    r"\bmake a decision\b": "decide",
    r"\bin the event that\b": "if",
    r"\bprior to\b": "before",
    r"\bsubsequent to\b": "after",
}

HEDGE_REPLACEMENTS = {
    r"\bmay or may not\b": "may",
    r"\bcould potentially\b": "could",
    r"\bmight possibly\b": "might",
    r"\bit appears that\b": "",
    r"\bit seems that\b": "",
    r"\bone could argue that\b": "",
    r"\bgenerally speaking,?\b": "",
}

BUZZWORD_REPLACEMENTS = {
    r"\bleverag(?:e|ing)\b": "use",
    r"\butiliz(?:e|ing)\b": "use",
    r"\bsynergistic\b": "cooperative",
    r"\bparadigm shift\b": "major change",
    r"\bgame-changer\b": "significant",
    r"\bnext-generation\b": "new",
    r"\bworld-class\b": "excellent",
    r"\bbest-in-class\b": "excellent",
    r"\bcutting-edge\b": "advanced",
}

REDUNDANT_QUALIFIERS = {
    r"\bcompletely finish(?:ed)?\b": "finished",
    r"\babsolutely essential\b": "essential",
    r"\b(?:totally|very) unique\b": "unique",
    r"\breally important\b": "important",
    r"\bvery important\b": "important",
    r"\bpast history\b": "history",
    r"\bfuture plans\b": "plans",
    r"\bend result\b": "result",
    r"\bfinal outcome\b": "outcome",
}

META_PATTERNS = [
    r"In this (?:article|post|document|section|guide),? (?:we will|I will|we|I) .*?[.!]\s*",
    r"As we (?:explore|examine|discuss) .*?,?\s",
    r"Let's take a (?:closer )?look at .*?[.!]\s*",
    r"Now that we've covered .*?,?\s",
    r"Before we proceed,?\s.*?[.!]\s*",
]

AGGRESSIVE_PATTERNS = [
    (r"^However,\s", ""),
    (r"^Furthermore,\s", ""),
    (r"^Moreover,\s", ""),
    (r"\bIt is (?:important|crucial|essential|vital) (?:that|to)\b", ""),
]


def apply_replacements(text, replacements):
    changes = 0
    for pattern, replacement in replacements.items():
        text, n = re.subn(pattern, replacement, text, flags=re.IGNORECASE)
        changes += n
    return text, changes


def clean(text, aggressive=False):
    total_changes = 0

    text, n = apply_replacements(text, PHRASE_REPLACEMENTS)
    total_changes += n

    text, n = apply_replacements(text, WORDY_REPLACEMENTS)
    total_changes += n

    text, n = apply_replacements(text, HEDGE_REPLACEMENTS)
    total_changes += n

    text, n = apply_replacements(text, BUZZWORD_REPLACEMENTS)
    total_changes += n

    text, n = apply_replacements(text, REDUNDANT_QUALIFIERS)
    total_changes += n

    for pattern in META_PATTERNS:
        text, n = re.subn(pattern, "", text, flags=re.IGNORECASE)
        total_changes += n

    if aggressive:
        for pattern, repl in AGGRESSIVE_PATTERNS:
            text, n = re.subn(pattern, repl, text, flags=re.MULTILINE)
            total_changes += n

    # Normalize spacing artifacts from deletions
    text = re.sub(r" {2,}", " ", text)
    text = re.sub(r" +([.,;:!?])", r"\1", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r",\s*,", ",", text)

    return text.strip(), total_changes


def preview(filepath, aggressive=False):
    original = Path(filepath).read_text(encoding="utf-8")
    cleaned, changes = clean(original, aggressive)

    if cleaned == original:
        print("No changes needed — text is clean.")
        return

    orig_lines = original.split("\n")
    clean_lines = cleaned.split("\n")

    print(f"\nPreview: {Path(filepath).name}")
    print(f"{'=' * 50}\n")

    shown = 0
    for i, (orig, cln) in enumerate(zip(orig_lines, clean_lines), 1):
        if orig != cln and shown < 10:
            print(f"  Line {i}:")
            print(f"    - {orig[:80]}")
            print(f"    + {cln[:80]}")
            print()
            shown += 1

    if shown == 10:
        print("  ... more changes not shown")

    print(f"Total changes: {changes}")
    print("Run with --save to apply.")


def save(filepath, output_path=None, aggressive=False):
    original = Path(filepath).read_text(encoding="utf-8")
    cleaned, changes = clean(original, aggressive)

    target = Path(output_path) if output_path else Path(filepath)
    if not output_path:
        backup = target.with_suffix(target.suffix + ".backup")
        Path(filepath).rename(backup)
        print(f"Backup: {backup}")

    target.write_text(cleaned, encoding="utf-8")
    print(f"Saved: {target}")
    print(f"Changes: {changes}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python clean_slop.py <file> [--save] [--output FILE] [--aggressive]")
        sys.exit(1)

    path = sys.argv[1]
    if not Path(path).exists():
        print(f"Error: '{path}' not found")
        sys.exit(1)

    aggressive = "--aggressive" in sys.argv
    save_mode = "--save" in sys.argv
    output = None
    if "--output" in sys.argv:
        idx = sys.argv.index("--output")
        if idx + 1 < len(sys.argv):
            output = sys.argv[idx + 1]
            save_mode = True

    if save_mode:
        save(path, output, aggressive)
    else:
        preview(path, aggressive)
