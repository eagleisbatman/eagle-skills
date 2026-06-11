# Any Stack: Deriving the Idioms

For languages without a dedicated reference file. All rules in SKILL.md and `universal-slop.md` apply in full. This file adds a protocol for writing idiomatic code in a stack the skill doesn't cover explicitly — Go, Rust, Kotlin, Java, Ruby, PHP, C#, Dart, Elixir, shell, SQL, anything.

## Derive conventions from the repo, in this order

1. **Lint/format config is law.** Find it (`.golangci.yml`, `rustfmt.toml`, `.editorconfig`, `ktlint`, `rubocop.yml`, `analysis_options.yaml`, etc.) and write code that passes it on the first try.
2. **The three most-touched files in the area you're editing** define local style: naming, error handling, module layout, test structure. `git log --oneline -- <dir>` or just read the neighbors. Match them even where you'd choose differently.
3. **The dependency manifest** (`go.mod`, `Cargo.toml`, `build.gradle`, `Gemfile`, `composer.json`, `pubspec.yaml`) defines the approved toolbox. Never add a dependency without checking whether an existing one — or the standard library — already does the job.
4. **The language's own canon** fills remaining gaps: Effective Go, the Rust API guidelines, Kotlin coding conventions, PEP 8 equivalents. Default to what the official style guide says, not what generic OOP habits suggest.

## Universal idiom rules that transfer to every language

- Use the language's native error mechanism the way the canon prescribes — Go returns errors and checks them at the call site, Rust propagates `Result` with `?`, exceptions-based languages throw and catch at boundaries. Don't import another language's error style.
- Use the standard library before reaching for a package. Every ecosystem has a slop pattern of installing a dependency for ten lines of stdlib.
- Concurrency primitives follow the platform: goroutines/channels in Go, tokio/async in Rust per the project's runtime, coroutines in Kotlin. Never hand-roll threading where the language has a first-class model.
- Respect the community's structural norms: Go keeps packages flat and avoids `pkg/utils`; Rust splits by module not by class; Java/Kotlin projects follow their existing package hierarchy. The repo shows which norms this team follows — extend them, don't reform them.
- Tests live where the ecosystem puts them (`_test.go` next to source, `#[cfg(test)]` modules, `src/test/...`) and use the project's existing test framework, not a new one.

## When the repo is greenfield (no conventions to read)

Pick the most boring, most official option at every fork: the standard formatter with default settings, the standard test runner, the standard project layout from the language's own documentation. Boring defaults are what the next maintainer — human or agent — will expect.
