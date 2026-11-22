# Global Claude Code Instructions

## Development Workflow

Use the existing `opusplan` setup:
- Opus High owns architecture and planning in Plan Mode.
- Sonnet High owns implementation, debugging, and testing in Execution Mode.
- Opus High performs independent final review when explicitly invoked.

These instructions do not set model selection or reasoning effort. Preserve the existing Claude Code configuration.

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

### During Final Review — Opus High

Opus owns the independent review. Explore may assist with locating evidence but must not perform the final review or make its decisions.

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
