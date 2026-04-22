#!/usr/bin/env python3
"""Scans text and code files for common AI-generated slop patterns."""

import re
import sys
from collections import defaultdict
from pathlib import Path

HIGH_RISK = [
    r"delve into",
    r"dive deep into",
    r"navigate the complexit(?:y|ies)",
    r"in the ever-evolving landscape",
    r"in today's fast-paced world",
    r"in today's digital age",
    r"it'?s important to note that",
    r"it'?s worth noting that",
]

MEDIUM_RISK = [
    r"however,? it is important to",
    r"furthermore",
    r"moreover",
    r"in essence",
    r"that being said",
]

BUZZWORDS = [
    r"synergistic",
    r"holistic approach",
    r"paradigm shift",
    r"game-changer",
    r"cutting-edge",
    r"next-generation",
    r"world-class",
    r"best-in-class",
    r"\bleverage\b",
    r"\butilize\b",
    r"unlock potential",
    r"drive innovation",
]

META_COMMENTARY = [
    r"in this (?:article|post|document|section)",
    r"as we (?:explore|examine|discuss)",
    r"let'?s take a (?:closer )?look",
    r"now that we'?ve covered",
    r"before we proceed",
]

HEDGE_WORDS = [
    r"may or may not",
    r"could potentially",
    r"might possibly",
    r"it appears that",
    r"it seems that",
    r"one could argue",
    r"generally speaking",
]

CODE_COMMENTS = [
    r"#\s*(?:Create|Initialize|Set up|Get|Return|Loop through|Increment|Process)\s+(?:the|a|an)\s+\w+",
    r"//\s*(?:Create|Initialize|Set up|Get|Return|Loop through|Increment|Process)\s+(?:the|a|an)\s+\w+",
]

WEIGHTS = {
    "high_risk": 15,
    "medium_risk": 8,
    "buzzwords": 5,
    "meta_commentary": 10,
    "hedging": 6,
    "obvious_comments": 12,
    "structure": 20,
}


def find_patterns(lines, patterns, category):
    findings = []
    for i, line in enumerate(lines, 1):
        for pattern in patterns:
            for match in re.finditer(pattern, line, re.IGNORECASE):
                findings.append({
                    "line": i,
                    "text": line.strip(),
                    "match": match.group(),
                })
    return findings


def analyze_structure(lines):
    issues = []
    if lines:
        first_para = " ".join(lines[:5])
        if re.search(r"in this .+ (?:will|we)", first_para, re.IGNORECASE):
            issues.append("Opening meta-commentary instead of content")

    transitions = ["however", "furthermore", "moreover", "additionally",
                    "nevertheless", "consequently", "therefore"]
    non_empty = [l for l in lines if l.strip()]
    if non_empty:
        starts = sum(1 for l in non_empty
                     if any(l.strip().lower().startswith(t) for t in transitions))
        ratio = starts / len(non_empty)
        if ratio > 0.3:
            issues.append(f"{ratio:.0%} of paragraphs start with transition words")
    return issues


def calculate_score(findings, word_count):
    raw = sum(len(findings[cat]) * WEIGHTS.get(cat, 5) for cat in findings)
    if word_count > 0:
        raw = int((raw / word_count) * 1000)
    return min(raw, 100)


def grade(score):
    if score < 20:
        return "Low slop — writing appears authentic"
    if score < 40:
        return "Moderate slop — some generic patterns"
    if score < 60:
        return "High slop — many AI patterns found"
    return "Severe slop — heavily generic"


def scan(filepath, verbose=False):
    text = Path(filepath).read_text(encoding="utf-8")
    lines = text.split("\n")

    findings = defaultdict(list)
    findings["high_risk"] = find_patterns(lines, HIGH_RISK, "high_risk")
    findings["medium_risk"] = find_patterns(lines, MEDIUM_RISK, "medium_risk")
    findings["buzzwords"] = find_patterns(lines, BUZZWORDS, "buzzwords")
    findings["meta_commentary"] = find_patterns(lines, META_COMMENTARY, "meta_commentary")
    findings["hedging"] = find_patterns(lines, HEDGE_WORDS, "hedging")
    findings["obvious_comments"] = find_patterns(lines, CODE_COMMENTS, "obvious_comments")

    structure_issues = analyze_structure(lines)
    findings["structure"] = [{"issue": i} for i in structure_issues]

    word_count = len(text.split())
    score = calculate_score(findings, word_count)

    print(f"\n{'=' * 60}")
    print(f"Slop Report: {Path(filepath).name}")
    print(f"{'=' * 60}\n")
    print(f"Score: {score}/100 — {grade(score)}\n")

    for category, items in findings.items():
        if not items:
            continue
        label = category.replace("_", " ").upper()
        print(f"  {label} ({len(items)})")
        limit = None if verbose else 3
        for item in items[:limit]:
            if "line" in item:
                print(f"    Line {item['line']}: \"{item['match']}\"")
            elif "issue" in item:
                print(f"    {item['issue']}")
        if limit and len(items) > limit:
            print(f"    ... and {len(items) - limit} more")
        print()

    if score > 20:
        print("Recommendations:")
        if findings["high_risk"]:
            print("  - Replace high-risk phrases with direct language")
        if findings["buzzwords"]:
            print("  - Remove buzzwords; use concrete terms")
        if findings["meta_commentary"]:
            print("  - Delete meta-commentary; lead with content")
        if findings["hedging"]:
            print("  - Reduce hedging; be direct")
        if findings["obvious_comments"]:
            print("  - Remove comments that restate code")
        print()

    return score


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python detect_slop.py <file> [--verbose]")
        sys.exit(1)
    path = sys.argv[1]
    if not Path(path).exists():
        print(f"Error: '{path}' not found")
        sys.exit(1)
    scan(path, verbose="--verbose" in sys.argv or "-v" in sys.argv)
