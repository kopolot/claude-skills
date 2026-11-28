# Global Claude Code Instructions

## Development Workflow

Use the existing `opusplan` setup:
- Opus Medium owns standard planning in Plan Mode.
- Opus High owns complex planning when explicitly invoked via /planhigh.
- Sonnet Medium owns implementation, debugging, and testing in Execution Mode.
- Sonnet High is reserved for complex implementation or debugging when explicitly requested.
- Opus Medium performs standard independent final review.
- Opus High is reserved for critical reviews.

## Research Delegation

### During Plan Mode — Opus High

Opus owns architectural decisions and implementation planning.

For substantial factual codebase discovery, prefer the Explore subagent (Haiku):
- Find relevant files, symbols, and existing patterns.
- Trace call sites, dependencies, and data flows.
- Locate tests, integration points, and constraints.

Delegate focused research questions with clear scope. Use the Plan subagent or investigate directly when deeper reasoning is required.

Treat Explore output as evidence, not conclusions. Verify critical claims and assumptions before making architectural decisions. Resolve uncertainty and conflicting findings independently.

### During Execution Mode — Sonnet High

Sonnet owns implementation and testing.

Use Explore for non-trivial repository searches or mapping unfamiliar modules when it will save time or main-agent context.

Sonnet independently makes implementation decisions, edits code, runs tests, resolves failures, and verifies results. Never delegate implementation decisions to Haiku.

### During Final Review — Opus Medium by default

Opus owns the independent review. Use Medium for normal reviews and High for security-sensitive or high-risk changes, or when explicitly requested. Explore may assist with locating evidence but must not perform the final review or make its decisions.

For the installed review plugins, the review model, the `/code-review` scope level and the review agent's reasoning effort are selected via `~/.claude/przeglad-petla/model`, `~/.claude/przeglad-petla/poziom` and `~/.claude/przeglad-petla/effort`. These are initialized to `opus`, `medium` and `medium` by `install.sh` only if missing. Explicit plugin flags and existing user preferences take precedence; this file alone cannot switch the running model's effort.

## Delegation Guidelines

- Delegate factual discovery, not entire features or architecture.
- Prefer concise findings with file paths, symbols, and line numbers.
- Verify important details directly; don't redo complete research without a reason.
- Do not delegate trivial lookups or create agents unnecessarily.
- Avoid parallel exploration when coordination overhead outweighs the benefit.
- Optimize for overall task quality and completion time, not model-call count alone.

## General Engineering Principles

- Follow repository conventions and project-specific instructions.
- Prefer simple, maintainable solutions and avoid unnecessary abstractions.
- Validate changes with relevant tests and tools.
- Distinguish verified facts from assumptions.
- Clearly report unresolved issues and limitations.
