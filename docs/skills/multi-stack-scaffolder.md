# Eagle Multi-Stack Scaffolder

Research-driven project scaffolding for 13+ technology stacks.

## What it does

Researches current best practices via web search BEFORE generating any code, documents every dependency choice with a written justification, and uses modern tooling (Bun for JS/TS, uv for Python, cargo for Rust, SPM for Swift).

## Command

```
/eagle-multi-stack-scaffolder
```

Also triggers on: "scaffold", "new project", "create app", "bootstrap", "set up project", "initialize codebase", "start new application"

## Supported stacks

| Category | Stacks |
|----------|--------|
| **Mobile** | SwiftUI (iOS/macOS), Jetpack Compose (Android), Kotlin XML Views, Flutter, Expo React Native |
| **Backend** | Node.js/Express, FastAPI, Flask, Django, Rust/Axum |
| **Web** | Next.js (React), Nuxt.js (Vue) |
| **Architecture** | Turborepo monorepo |

## Required inputs

- What you're building (app type, features, target platforms)

## Optional inputs

- Technology preferences
- Existing backend/services to integrate with

## Output

Scaffolded project with:
- Documentation (RESEARCH.md, DEPENDENCIES.md, STRUCTURE.md, SETUP.md)
- Configuration files
- Production-ready boilerplate
- Written justification for every dependency

## Example

```
You: I want to build a fitness tracking app for iOS and Android with a Python backend
Claude: [identifies stacks: Expo React Native + FastAPI, reads reference files,
        researches current best practices, generates docs + scaffold]
```

## How it works

7-step process: clarify requirements, identify stacks, read reference files, web research for current best practices, generate documentation, scaffold code, verify setup commands.
