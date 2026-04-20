# Agent Instructions

## Scope

These instructions apply to the whole repository.

## Workflow

- Use the Gradle wrapper from the repository root. Do not substitute local Gradle installations or ad hoc build commands.
- Run `./gradlew build --parallel` after code changes before finishing. This is the repository's canonical verification path and matches the configured pre-commit hook.
- Keep working from the repository root unless a task clearly targets a single module.
- Prefer small changes that preserve the current multi-module layout: `protelis.parser` for the grammar and parser, `protelis.parser.ide` for IDE/server support, and `protelis.parser.web` for the web packaging and demo server.

## Code Changes

- Preserve the existing Kotlin Gradle DSL and Xtext/Xtend structure. Extend current tasks and source sets instead of introducing parallel build logic.
- When parser behavior changes, update or add tests in `protelis.parser/src/test/java/org/protelis/parser/tests/ProtelisParsingTest.xtend`.
- Do not hand-edit generated output when the source grammar or MWE2 workflow is the real source of truth. Change the grammar or generator inputs and let Gradle regenerate what is needed.
- Keep Java compatibility assumptions aligned with the build: compilation targets Java 17 and the project runs tests across multiple JVMs through the repository plugins.

## Validation And Failures

- If `./gradlew build --parallel` fails, fix the code or build logic and rerun it until it passes. Do not stop after a partial fix.
- Treat warnings and suppressions as a last resort. Prefer a real fix first.
- Every suppression must include a short justification near the suppression site. Avoid blanket or unexplained suppressions.

## Commits

- Use conventional commit headers in the form `type(scope): summary`, matching the repository's commit-msg hook.
- Use `type(scope)!: summary` plus a `BREAKING CHANGE:` footer for breaking changes.
- Keep commit subjects imperative, specific, and release-relevant.
