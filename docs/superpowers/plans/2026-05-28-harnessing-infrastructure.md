# Harnessing Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete four-layer AI coding harness into this repo — instruction, planning, execution, and evaluation artifacts — so it functions as both a working harness and a reference template for future repos.

**Architecture:** All artifacts are markdown or shell files organized into named layers. No build step, no dependencies. Layer 1 (CLAUDE.md + agent-rules) constrains sessions. Layer 2 (plans/) holds per-feature planning artifacts. Layer 3 (.claude/commands/) provides slash commands. Layer 4 (scripts/validate.sh + CI) gates completion.

**Tech Stack:** Bash (scripts), Markdown (all docs), GitHub Actions (CI)

---

## File Map

**Created:**
- `CLAUDE.md` — lean routing file, session rules
- `docs/agent-rules/conventions.md` — TS/JS naming and style rules
- `docs/agent-rules/safety-boundaries.md` — what the agent may/may not touch
- `docs/agent-rules/verification.md` — definition of done, three-state verdicts
- `plans/README.md` — explains plan directory structure
- `plans/_template/research.md` — template: truth about current system state
- `plans/_template/plan.md` — template: steps + write-scope contracts
- `plans/_template/behavior-locks.md` — template: invariants + proof conditions
- `plans/_template/session-state.md` — template: current step tracking
- `plans/_template/progress.md` — template: append-only session log
- `plans/_template/release-verdict.md` — template: three-state verdict
- `.claude/commands/harness-audit.md` — `/harness-audit` slash command
- `.claude/commands/harness-init.md` — `/harness-init` slash command
- `scripts/validate.sh` — unified validation entry point
- `.github/workflows/ci.yml` — CI that calls validate.sh

---

## Task 1: Commit the design doc

The spec was already written to `docs/superpowers/specs/2026-05-28-harnessing-infrastructure-design.md` during brainstorming but never committed.

- [ ] **Step 1: Stage and commit the spec and plan docs**

```bash
git add docs/superpowers/specs/2026-05-28-harnessing-infrastructure-design.md
git add docs/superpowers/plans/2026-05-28-harnessing-infrastructure.md
git commit -m "docs: add harnessing infrastructure spec and implementation plan"
```

Expected: commit succeeds, `git status` clean.

---

## Task 2: Layer 1 — CLAUDE.md

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Create CLAUDE.md**

Create `/CLAUDE.md` with exactly this content:

```markdown
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
```

- [ ] **Step 2: Verify line count is under 80**

```bash
wc -l CLAUDE.md
```

Expected: number is less than 80.

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md routing file (Layer 1)"
```

---

## Task 3: Layer 1 — docs/agent-rules/

**Files:**
- Create: `docs/agent-rules/conventions.md`
- Create: `docs/agent-rules/safety-boundaries.md`
- Create: `docs/agent-rules/verification.md`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p docs/agent-rules
```

- [ ] **Step 2: Create docs/agent-rules/conventions.md**

```markdown
# Conventions

## TypeScript / JavaScript

- **Naming:** camelCase for variables and functions; PascalCase for classes and types;
  SCREAMING_SNAKE_CASE for constants; kebab-case for file names
- **Imports:** named imports preferred over default exports; group order: external →
  internal → relative; blank line between groups
- **Types:** explicit return types on all exported functions; avoid `any`; use `unknown`
  when the type is genuinely unknown
- **Error handling:** never swallow errors silently; re-throw with context; use `Error`
  subclasses for domain-specific errors
- **Async:** prefer `async/await` over `.then()` chains

## File structure

- One module per file; one clear responsibility per module
- Test files co-located with source: `foo.ts` → `foo.test.ts`
- No barrel `index.ts` re-exports unless a module boundary genuinely requires one
- No `utils/` or `common/` buckets that mix unrelated concerns — name by responsibility

## Commits

- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- One logical change per commit
- Commit after each passing test, not in bulk at the end of a session
```

- [ ] **Step 3: Create docs/agent-rules/safety-boundaries.md**

```markdown
# Safety Boundaries

## Never touch without explicit approval

- `plans/_template/` — reference template; copy it, never edit it directly
- `.github/workflows/ci.yml` — CI configuration; changes affect all future runs
- Any file containing secrets, API keys, or credentials
- `package-lock.json` or `yarn.lock` — only when explicitly adding/removing a dependency

## Generated files

Mark generated files with `// @generated` at the top. Never edit generated files by hand.
If a generated file needs to change, change its generator.

## Dependency changes

Only add or remove npm dependencies when explicitly instructed. When adding a dependency,
check whether an existing one already covers the need. Always commit `package.json` and
the lock file together in the same commit.

## Scope discipline

Each plan step declares a write-scope contract listing exactly which files that step may
touch. If a change requires editing a file not listed, output `SCOPE QUESTION:` and wait
for human input. Do not silently expand scope.
```

- [ ] **Step 4: Create docs/agent-rules/verification.md**

```markdown
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
```

- [ ] **Step 5: Verify all three files exist**

```bash
ls docs/agent-rules/
```

Expected output: `conventions.md  safety-boundaries.md  verification.md`

- [ ] **Step 6: Commit**

```bash
git add docs/agent-rules/
git commit -m "feat: add agent-rules depth docs (Layer 1)"
```

---

## Task 4: Layer 2 — plans/ structure

**Files:**
- Create: `plans/README.md`
- Create: `plans/_template/research.md`
- Create: `plans/_template/plan.md`
- Create: `plans/_template/behavior-locks.md`
- Create: `plans/_template/session-state.md`
- Create: `plans/_template/progress.md`
- Create: `plans/_template/release-verdict.md`

- [ ] **Step 1: Create directories**

```bash
mkdir -p plans/_template
```

- [ ] **Step 2: Create plans/README.md**

```markdown
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
```

- [ ] **Step 3: Create plans/_template/research.md**

```markdown
# Research: [Feature Name]

> Truth only — how the system works today. No opinions, no proposals.
> Separate facts (verified from code/tests), inferences (probable but unverified),
> and unknowns (require experiment or human input).

## System context

<!-- Which parts of the system are relevant to this change? -->

## Facts

<!-- Verified from code, tests, or running the system. Include file paths. -->

## Inferences

<!-- Derived from facts but not directly verified. Mark as such. -->

## Unknowns

<!-- Open questions that need resolution before or during implementation. -->
```

- [ ] **Step 4: Create plans/_template/plan.md**

```markdown
# Plan: [Feature Name]

**Goal:** [One sentence describing what this builds]

**Source:** [PRD section, issue number, or decision that requested this change]

## Steps

### Step 1: [Name]

**Write scope:**
- `path/to/file.ts`
- `path/to/file.test.ts`

**Out of scope:** anything not listed above. If a file outside this list needs changing,
output `SCOPE QUESTION:` and wait.

**What to do:**
<!-- Step instructions here. Be specific. -->

---

### Step 2: [Name]

**Write scope:**
- `path/to/another.ts`

**What to do:**
<!-- Step instructions here. -->
```

- [ ] **Step 5: Create plans/_template/behavior-locks.md**

```markdown
# Behavior Locks: [Feature Name]

> Read this file at every session start. These invariants are non-negotiable.
> Each lock: a business-terms invariant, a proof condition, and the test that enforces it.

## Lock 1: [Name]

**Invariant:** [State the constraint in business terms, not code terms]

**Proof condition:** [What you would do to verify this holds — readable by anyone]

**Test coverage:** `tests/path/to/test.ts::testName`
(or "manually verified — no automated test" if none exists)

**Source:** [PRD section, ADR, or architectural decision that established this constraint]
```

- [ ] **Step 6: Create plans/_template/session-state.md**

```markdown
# Session State: [Feature Name]

> Updated by the agent at the end of each session. Never leave this stale.

## Current step

Step N: [Step name from plan.md]

## Status

[In progress | Blocked | Complete]

## Last action

[What was completed in the last session]

## Next action

[What to do first at the start of the next session]

## Blockers

[None | List any blockers preventing progress]
```

- [ ] **Step 7: Create plans/_template/progress.md**

```markdown
# Progress Log: [Feature Name]

> Append-only. Add an entry at the end of each session. Never delete or edit past entries.

---

## [YYYY-MM-DD]

- [What was completed this session]
- [Commits: hash or message]
```

- [ ] **Step 8: Create plans/_template/release-verdict.md**

```markdown
# Release Verdict: [Feature Name]

**Verdict:** [Proven | Conditionally proven | Not proven]

## Gates

- [ ] `scripts/validate.sh` — all checks pass
- [ ] Behavior locks — all proof conditions satisfied
- [ ] Scope compliance — no undeclared file edits

## Must-fix findings

[None | List blocking issues that prevent merge]

## Advisory findings

[None | List non-blocking findings with rationale for accepting them and tracking tickets]

## Merge recommendation

[Merge | Do not merge — reason]
```

- [ ] **Step 9: Verify all seven files exist**

```bash
ls plans/
ls plans/_template/
```

Expected `plans/`: `README.md  _template`
Expected `plans/_template/`: `behavior-locks.md  plan.md  progress.md  release-verdict.md  research.md  session-state.md`

- [ ] **Step 10: Commit**

```bash
git add plans/
git commit -m "feat: add plans/ structure and _template (Layer 2)"
```

---

## Task 5: Layer 3 — .claude/commands/

**Files:**
- Create: `.claude/commands/harness-audit.md`
- Create: `.claude/commands/harness-init.md`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p .claude/commands
```

- [ ] **Step 2: Create .claude/commands/harness-audit.md**

```markdown
Run the Agentic Legibility Framework audit on the current repository. Score each of the
nine dimensions using the 0–4 evidence rubric. All scores must be backed by concrete
evidence (file path, grep result, command output) — not inferred from intent.

## Evidence rubric

- 0: Missing or actively hostile to agent execution
- 1: Present in fragments, unreliable or inconsistent
- 2: Usable with manual inference and extra exploration
- 3: Clear and mostly complete for routine agent work
- 4: Explicit, current, machine-friendly, easy to act on

## Cluster 1: Navigation (40% of composite)

**Dim 1 — Repository Orientation (10%)**
Sub-metrics (score each 0–4):
- 1.1: Is there a CLAUDE.md or AGENTS.md at repo root that explains what the repo is?
- 1.2: Does it point to where key docs, rules, and entry points live?

**Dim 2 — Information Findability (10%)**
Sub-metrics:
- 2.1: Can the agent locate relevant context for a change without reading the whole repo?
- 2.2: Are module boundaries and cross-references documented?

**Dim 3 — Codebase Navigability (20%)**
Sub-metrics:
- 3.1: Are file and function names descriptive enough to predict behavior before opening?
- 3.2: Is the directory structure predictable (no overloaded utils/ or common/ buckets)?

## Cluster 2: Execution (30%)

**Dim 4 — Task Executability (10%)**
Sub-metrics:
- 4.1: Is there a bootstrap/setup script that is idempotent and documented?
- 4.2: Are runbooks present for high-frequency change types?

**Dim 5 — Verification Legibility (10%)**
Sub-metrics:
- 5.1: Is there a single unified validation command (`scripts/validate.sh` or equivalent)?
- 5.2: Does CI run the exact same command (CI parity)?
- 5.3: Is there a clear, readable definition of done?

**Dim 7 — Safety Boundaries (10%)**
Sub-metrics:
- 7.1: Are generated files marked so the agent knows not to edit them?
- 7.2: Are risky or sensitive paths explicitly documented?
- 7.3: Are write-scope constraints specified per plan step?

## Cluster 3: Intent (30%)

**Dim 6 — Intent and Invariants (15%)**
Sub-metrics:
- 6.1: Are load-bearing invariants documented as behavior locks?
- 6.2: Do behavior locks have proof conditions and test pointers?

**Dim 8 — Machine-Friendliness (10%)**
Sub-metrics:
- 8.1: Are naming and structural conventions written down?
- 8.2: Are interface contracts or schema docs present where relevant?

**Dim 9 — Freshness and Trustworthiness (5%)**
Sub-metrics:
- 9.1: Is there CI drift detection (e.g., commands in docs are tested)?
- 9.2: Do behavior lock test pointers point at tests that currently exist?

## Output format

For each sub-metric: state the score and the concrete evidence.
Compute each dimension average. Compute the weighted composite.

Map composite to tier:
- 0.0–0.9: Unaware
- 1.0–1.9: Nascent
- 2.0–2.9: Structured
- 3.0–3.5: Established
- 3.6–4.0: Exemplary

End with a prioritized improvement backlog in this order:
1. Runnability (Dim 4, 5) — if below 3
2. Orientation (Dim 1) — if below 3
3. Invariants (Dim 6, 7) — if below 3
4. Runbooks (Dim 4.2) — if below 3
5. Metadata (Dim 8) — if below 3
```

- [ ] **Step 3: Create .claude/commands/harness-init.md**

```markdown
Initialize an AI coding harness in the current repository. Run from within the target repo.

## Steps

### 1. Gather context

Ask the user two questions (one at a time):
- "What is this repository for? (one sentence)"
- "What is the primary language/stack? (e.g., TypeScript, Python, Go)"

### 2. Create CLAUDE.md

Generate `CLAUDE.md` at the repo root with these sections:
- **What this repo is:** use the user's one-sentence description
- **Session lifecycle:** read order — CLAUDE.md → behavior-locks.md → plan.md → session-state.md; confirm before acting
- **Verification gate:** `scripts/validate.sh` must pass before declaring done
- **Write scope:** stay within plan step's declared files; output `SCOPE QUESTION:` otherwise
- **Hard stops:** never bypass validate.sh; never modify plans/_template/ without approval; never commit secrets
- **References:** docs/agent-rules/ for conventions, safety, verification

Keep it under 80 lines.

### 3. Create docs/agent-rules/

Create `docs/agent-rules/` with three files:

**conventions.md** — naming, imports, error handling, file structure, commit style for the identified stack:
- TypeScript: camelCase vars/fns, PascalCase types, explicit return types, no `any`, co-located tests
- Python: snake_case vars/fns, PascalCase classes, type hints on all public functions, pytest tests beside source
- Other stacks: ask the user for the key conventions

**safety-boundaries.md** — standard content (plans/_template/ locked, CI locked, no secrets, scope discipline)

**verification.md** — standard content (definition of done, three-state verdicts, verification sequence, post-compact protocol)

### 4. Create plans/ structure

Create `plans/README.md` (standard content: naming, files table, session start protocol, don't delete after merge).

Create `plans/_template/` with these six files (use standard template content):
- research.md, plan.md, behavior-locks.md, session-state.md, progress.md, release-verdict.md

### 5. Create scripts/validate.sh

Generate `scripts/validate.sh` for the identified stack:

**TypeScript/JavaScript:**
```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if [ ! -f "package.json" ]; then echo "No package.json — skipping"; exit 0; fi
echo "=== Type check ===" && npx tsc --noEmit
echo "=== Lint ===" && npx eslint .
echo "=== Tests ===" && npx jest --passWithNoTests
echo "=== Build ===" && npm run build --if-present
echo "=== All checks passed ==="
```

**Python:**
```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "=== Type check ===" && python -m mypy .
echo "=== Lint ===" && python -m ruff check .
echo "=== Tests ===" && python -m pytest
echo "=== All checks passed ==="
```

Make the script executable: `chmod +x scripts/validate.sh`

### 6. Create .github/workflows/ci.yml

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4   # remove for non-JS stacks
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci --if-present      # remove for non-JS stacks
      - run: bash scripts/validate.sh
```

Adjust the setup steps for the identified stack.

### 7. Report and suggest commit

List every file created. Then output:

```
Harness initialized. Review the files above, then commit:

  git add -A
  git commit -m "chore: initialize AI coding harness"

After committing, run /harness-audit to see your starting legibility score.
```
```

- [ ] **Step 4: Verify both command files exist**

```bash
ls .claude/commands/
```

Expected: `harness-audit.md  harness-init.md`

- [ ] **Step 5: Commit**

```bash
git add .claude/
git commit -m "feat: add harness-audit and harness-init slash commands (Layer 3)"
```

---

## Task 6: Layer 4 — scripts/validate.sh and CI

**Files:**
- Create: `scripts/validate.sh`
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create the directories**

```bash
mkdir -p scripts .github/workflows
```

- [ ] **Step 2: Create scripts/validate.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Unified validation script — the single source of truth for "done".
# CI runs this same script. Add no extra steps to CI that don't run locally.
#
# Template repo behavior: if no package.json is present, skips JS/TS checks.
# In a real project, remove the guard and fill in the actual checks.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ ! -f "package.json" ]; then
  echo "No package.json found — skipping JS/TS checks (template repo mode)."
  echo "In a real project: remove this guard and add tsc, eslint, jest, and build steps."
  exit 0
fi

echo "=== Type check ==="
npx tsc --noEmit

echo "=== Lint ==="
npx eslint .

echo "=== Tests ==="
npx jest --passWithNoTests

echo "=== Build ==="
npm run build --if-present

echo ""
echo "=== All checks passed ==="
```

- [ ] **Step 3: Make validate.sh executable**

```bash
chmod +x scripts/validate.sh
```

- [ ] **Step 4: Run validate.sh to verify it exits 0**

```bash
bash scripts/validate.sh
```

Expected output:
```
No package.json found — skipping JS/TS checks (template repo mode).
In a real project: remove this guard and add tsc, eslint, jest, and build steps.
```
Expected exit code: 0

- [ ] **Step 5: Create .github/workflows/ci.yml**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Remove the next two steps for non-JS/TS projects.
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci --if-present

      - run: bash scripts/validate.sh
```

- [ ] **Step 6: Commit**

```bash
git add scripts/validate.sh .github/workflows/ci.yml
git commit -m "feat: add validate.sh and CI workflow (Layer 4)"
```

---

## Task 7: Smoke test — run /harness-audit on this repo

With all layers in place, run the audit command to verify the harness scores correctly and the audit output is useful.

- [ ] **Step 1: Run /harness-audit**

Type `/harness-audit` in the Claude Code session.

Expected: audit walks through all 9 dimensions, produces a composite score, and outputs a prioritized improvement backlog. The repo should score in the **Established (3.0–3.5)** range given the four layers now present.

- [ ] **Step 2: Note any improvement backlog items**

If the audit surfaces gaps (likely Dim 3 codebase navigability — no source code yet, and Dim 4.1 setup reproducibility — no bootstrap script), note them. These are expected for a template repo with no project code.

- [ ] **Step 3: Final git status check**

```bash
git status
git log --oneline -7
```

Expected: clean working tree. Seven commits:
1. Initial commit
2. docs: add harnessing infrastructure spec and implementation plan
3. feat: add CLAUDE.md routing file (Layer 1)
4. feat: add agent-rules depth docs (Layer 1)
5. feat: add plans/ structure and _template (Layer 2)
6. feat: add harness-audit and harness-init slash commands (Layer 3)
7. feat: add validate.sh and CI workflow (Layer 4)
