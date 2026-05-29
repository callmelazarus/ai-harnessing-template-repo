# Verification

## Definition of done

A task is done when ALL of the following are true:

1. `scripts/validate.sh` exits 0 — all checks pass
2. All behavior locks in the current plan have their proof conditions satisfied
3. A release verdict is written to the current plan's `release-verdict.md`

Never declare done based on code inspection alone. Run the checks.

## Three-state verdicts

| Verdict | Meaning | Proceed? |
|---|---|---|
| **Proven** | All gates pass, no findings | Yes — merge-ready |
| **Conditionally proven** | Gates pass; advisory findings accepted with documented rationale | Yes — track findings |
| **Not proven** | Gate failures or must-fix findings present | No — return to planning |

## Verification sequence

1. Run `scripts/validate.sh`
2. Check each behavior lock's proof condition in the current plan
3. Write release verdict to `plans/<current-plan>/release-verdict.md`
4. Commit

## After /compact or /clear

Re-read in order: `CLAUDE.md`, current `behavior-locks.md`, current `plan.md`, current
`session-state.md`. State the current step aloud before any action.
