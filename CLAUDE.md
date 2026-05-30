# Agent Rules

Lean routing file. Detail lives in `docs/agent-rules/`.

## What this repo is

AI harnessing template and reference implementation. Provides a four-layer harness
structure (instruction, planning, execution, evaluation) for TypeScript/JavaScript projects.
Clone this repo and adapt it as the starting harness for a new project.

## Session lifecycle

At session start, read in order:
1. This file
2. Current feature's `behavior-locks.md` (if a plan is active in `docs/designs/`)
3. Current feature's `plan.md`
4. Current feature's `session-state.md`

Confirm by stating what you read before any action.

## Session updates

After each task completes, update `session-state.md` with the current step, status,
last action, next action, and any blockers. Do not wait until end of session.

At end of session (or before any interruption), also append an entry to `progress.md`
summarising what was completed and listing commit hashes. Both files live in the
feature's `docs/designs/YYYY-MM-DD-<feature>/` directory.

## Verification gate

Before declaring any task done, run `scripts/validate.sh`. All checks must pass.

## Write scope

Touch only files listed in the current plan step's write scope. If you need to touch
a file not listed, output `SCOPE QUESTION:` and wait for human input. Never expand
scope silently.

## Hard stops

- Never modify `docs/designs/_template/` without explicit approval
- Never bypass `scripts/validate.sh` (no `--no-verify`, no skipping)
- Never commit secrets or credentials
- Never modify `.github/workflows/ci.yml` without explicit approval

## Harness improvements

When you identify a gap in how the harness works — a missing rule, a file that should
exist but doesn't, a workflow that breaks down — fix it and append an entry to
`harness-improvement-log.md` at the repo root. Each entry: gap found, what changed, why
it matters.

## References

- Conventions: `docs/agent-rules/conventions.md`
- Safety boundaries: `docs/agent-rules/safety-boundaries.md`
- Verification depth: `docs/agent-rules/verification.md`
- Planning structure: `docs/designs/README.md`
- Framework reference: `docs/resources/hardness-engineering-guide.md`
