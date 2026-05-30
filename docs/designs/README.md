# Designs

Each feature or change gets its own dated subdirectory containing all artifacts:
design spec, research, plan, and session tracking.

## Naming

`docs/designs/YYYY-MM-DD-<slug>/` — e.g., `docs/designs/2026-05-29-auth-middleware/`

## Files

| File | What goes in it |
|---|---|
| `design.md` | Spec — what we're building and why. Produced during brainstorming. |
| `research.md` | Truth — how the system works today. No opinions, no proposals. |
| `plan.md` | Intent — what changes, why, steps with write-scope contracts. |
| `behavior-locks.md` | Invariants — each lock: invariant + proof condition + test pointer. |
| `session-state.md` | Current step — updated by the agent at the end of each session. |
| `progress.md` | Log — append-only record of completed work. Never delete entries. |
| `release-verdict.md` | Verdict — proven / conditionally proven / not proven. |

## Session start protocol

The agent reads at the start of every session:
`CLAUDE.md` → `behavior-locks.md` → `plan.md` → `session-state.md`

Keep these files current so any session can resume cleanly.

## After merge

Feature directories stay as a permanent record. Do not delete them after merging.
