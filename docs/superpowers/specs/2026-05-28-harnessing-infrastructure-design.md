# Harnessing Infrastructure Design

**Date:** 2026-05-28
**Status:** Approved

## What We're Building

A full four-layer AI coding harness built directly into this repo, following the Harness Engineering guide in `docs/resources/`. This repo serves as both a working harness and a reference template — new repos clone it and adapt it.

Stack: JavaScript / TypeScript.

---

## Architecture

```
ai-harnessing-template-repo/
│
├── CLAUDE.md                          ← Layer 1: lean routing (≤80 lines)
│
├── docs/
│   ├── resources/                     (existing — keep as-is)
│   └── agent-rules/                   ← Layer 1: depth
│       ├── conventions.md
│       ├── safety-boundaries.md
│       └── verification.md
│
├── plans/
│   ├── README.md                      ← Layer 2: explains the structure
│   └── _template/                     ← Layer 2: copy for each feature
│       ├── research.md
│       ├── plan.md
│       ├── behavior-locks.md
│       ├── session-state.md
│       ├── progress.md
│       └── release-verdict.md
│
├── .claude/
│   └── commands/
│       ├── harness-audit.md           ← Layer 3: /harness-audit slash command
│       └── harness-init.md            ← Layer 3: /harness-init slash command
│
├── scripts/
│   └── validate.sh                    ← Layer 4: unified validation entry point
│
└── .github/
    └── workflows/
        └── ci.yml                     ← Layer 4: CI parity
```

---

## Layer 1 — Instruction

### CLAUDE.md

Lean routing file, ≤80 lines. Covers:
- What this repo is (harness template and reference implementation)
- Mandatory session-start read order: `CLAUDE.md` → current plan's `behavior-locks.md` → `plan.md` → `session-state.md`
- Verification gate: `scripts/validate.sh` must pass before declaring done
- Write-scope rule: stay within the current plan step's declared files; output `SCOPE QUESTION:` and wait if a needed file is outside scope
- Hard stops: never bypass `validate.sh`, never edit `plans/_template/` without explicit approval
- References to `docs/agent-rules/` for conventions, safety, and verification depth

### docs/agent-rules/conventions.md

TypeScript/JavaScript conventions: naming patterns, file structure expectations, import style, error handling approach, test file co-location.

### docs/agent-rules/safety-boundaries.md

What the agent may and may not touch: generated files, config files requiring explicit approval, secrets handling, dependency changes.

### docs/agent-rules/verification.md

Definition of done: all `validate.sh` checks pass, behavior locks verified, release verdict written. Three-state verdict format (proven / conditionally proven / not proven).

---

## Layer 2 — Planning

### plans/README.md

Explains the planning workflow: when to create a plan dir, how to name it (`YYYY-MM-<slug>`), what each file is for, and how the agent reads them at session start.

### plans/_template/

Template files for a new feature or change:

| File | Purpose |
|---|---|
| `research.md` | Truth — how the system works today. No opinions, no proposals. |
| `plan.md` | Intent — what changes, why, step-by-step with write-scope contracts per step. |
| `behavior-locks.md` | Invariants — each lock has: invariant statement, proof condition, test pointer. |
| `session-state.md` | Current step — updated by the agent each session. |
| `progress.md` | Log — append-only record of completed work. |
| `release-verdict.md` | Verdict — proven / conditionally proven / not proven, with gate results and advisory findings. |

Each template file has a header comment explaining its purpose and the format to follow.

---

## Layer 3 — Execution

### .claude/commands/harness-audit.md

A `/harness-audit` slash command that walks through the 9-dimension Agentic Legibility Framework from the guide. For each dimension, the agent gathers concrete evidence and scores 0–4. Outputs a composite score, tier label, and prioritized improvement backlog ordered by the guide's remediation priority (runnability → orientation → invariants → runbooks → metadata).

### .claude/commands/harness-init.md

A `/harness-init` slash command that, when run in a new repo, guides the agent to:
1. Ask the user for the repo's purpose and stack
2. Generate a customized `CLAUDE.md` for that repo
3. Copy the `plans/_template/` structure
4. Generate a starter `scripts/validate.sh` for the identified stack
5. Add a `docs/agent-rules/` stub directory with placeholder files

---

## Layer 4 — Evaluation

### scripts/validate.sh

A template validation script demonstrating the pattern for TS/JS projects. Since this repo has no project source code, the script checks for the presence of a `package.json` and skips checks gracefully if none exists. When this template is adapted into a real project, the operator fills in the actual checks. The intended order for concrete projects:

1. `tsc --noEmit` — type-check
2. `eslint .` — lint
3. `jest` (or `vitest`) — tests
4. `npm run build` — build verification

Exits non-zero on first failure. Each check prints a clear header so failures are easy to locate.

### .github/workflows/ci.yml

CI workflow that calls `scripts/validate.sh` exactly as the agent does locally — no additional steps, no omissions. Ensures CI parity: if validate passes locally, CI passes. In this template repo, CI will pass trivially (no project code); in a concrete repo the same workflow runs real checks.

---

## Key Design Decisions

**Plans per feature, not per repo.** Each change gets its own `plans/<date-slug>/` directory containing the full story of that change. A reviewer or future agent opens that one folder and understands what was built, why, and what invariants were established.

**Template stays untouched.** `plans/_template/` is never edited directly — it's always copied. This ensures the template stays clean and the agent can rely on it as a stable reference.

**validate.sh is the single source of truth for done.** The agent never declares a task complete without running it. CI runs the same command. No divergence possible.

**CLAUDE.md ≤80 lines.** Enforced by design. Depth lives in `docs/agent-rules/`. A 6,000-line routing file is a known failure mode; the constraint is explicit.

**Slash commands, not skills.** The harness management tools (`/harness-audit`, `/harness-init`) live as user-invoked slash commands in `.claude/commands/`. They're operational tools, not automatic behaviors.
