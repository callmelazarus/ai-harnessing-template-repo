# Plans

Each feature or change gets its own dated subdirectory. Copy `_template/` to start.

## Naming

`plans/YYYY-MM-<slug>/` — e.g., `plans/2026-05-auth-middleware/`

## Files

| File | What goes in it |
|---|---|
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

Plan directories stay as a permanent record. Do not delete them after merging.
