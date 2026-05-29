# Agent Rules

Lean routing file. Detail lives in `docs/agent-rules/`.

## What this repo is

AI harnessing template and reference implementation. Provides a four-layer harness
structure (instruction, planning, execution, evaluation) for TypeScript/JavaScript projects.
Clone this repo and adapt it as the starting harness for a new project.

## Session lifecycle

At session start, read in order:
1. This file
2. Current plan's `behavior-locks.md` (if a plan is active in `plans/`)
3. Current plan's `plan.md`
4. Current plan's `session-state.md`

Confirm by stating what you read before any action.

## Verification gate

Before declaring any task done, run `scripts/validate.sh`. All checks must pass.

## Write scope

Touch only files listed in the current plan step's write scope. If you need to touch
a file not listed, output `SCOPE QUESTION:` and wait for human input. Never expand
scope silently.

## Hard stops

- Never modify `plans/_template/` without explicit approval
- Never bypass `scripts/validate.sh` (no `--no-verify`, no skipping)
- Never commit secrets or credentials
- Never modify `.github/workflows/ci.yml` without explicit approval

## References

- Conventions: `docs/agent-rules/conventions.md`
- Safety boundaries: `docs/agent-rules/safety-boundaries.md`
- Verification depth: `docs/agent-rules/verification.md`
- Planning structure: `plans/README.md`
- Framework reference: `docs/resources/hardness-engineering-guide.md`
