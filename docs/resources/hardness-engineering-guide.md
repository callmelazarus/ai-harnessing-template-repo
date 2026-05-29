# Harness Engineering: A Practitioner’s Field Guide

A practitioner’s reference for the discipline of designing the runtime environment around your coding agents. Covers what a production-grade harness contains, how to measure whether yours is good, the disciplines that keep it alive, and the operational moves that earn their compute cost.

---

## How to Read This

This guide complements the Harness-Driven Delivery session. The session names the discipline, walks the inventory at a glance, and applies one published measurement framework to one repo. This guide goes wider on the parts the session doesn’t deep-dive on: the operational artifacts of each layer, the 3-layer guardrail model, the disciplines that keep a harness from rotting, and the customization moves that make a published framework actually fit your work.

**If you’ve finished the session and the walkthrough,** skim the table of contents and jump to whatever you didn’t get to apply. The framework details (§6) are in the walkthrough already; the parts you probably didn’t touch are §4 (planning-layer artifacts), §5 (evaluation layer in depth), §7 (3-layer guardrails), and §10 (operational disciplines).

**If you’re new to the topic,** read straight through. The order builds.

---

## 1. What Harness Engineering Is

### Agent = Model + Harness

The model is the LLM weights — fungible, this year’s frontier model, what you don’t get to choose. The **harness** is everything else: the runtime environment you build around it. Ground rules, skills, hooks, subagents, MCP servers, plans, research documents, verification scripts. Every one of them is a file in your repo that the agent reads at the start of every session (or that the runtime invokes deterministically). The harness is not a prompt. It is infrastructure that persists independently of any conversation.

**Harness engineering** is the discipline of designing that runtime environment. The leverage compounds because what you encode once, every future session inherits.

### The Three Peer Disciplines

Three disciplines work at different scopes:

| Discipline | Unit of work | Lifespan |
| --- | --- | --- |
| Prompt engineering | One message turn | This message |
| Context engineering | One session window | This session |
| **Harness engineering** | The repository | Every session, every agent |

Harness engineering is the widest of the three. Same engineering you already practice — just at a different operating scope.

### Why the Unit of Work Is the Repo

The repo is where the artifacts live, where they’re versioned, where they survive context resets, and where they’re shared across teammates. A harness that lives only in one engineer’s habits is not engineered — it is folklore. The discipline is to *write down* the rules, gates, and patterns in files the agent can read, so that the next session, the next teammate, and the next agent all inherit them.

---

## 2. Why Capable Agents Still Need a Harness

The best frontier models are *capable*. They are not reliable without structure. Five failure modes show up regardless of which model or which tool:

**Scope drift.** The agent edits files it was not asked to touch. It “improves” related code while implementing the requested feature. The change is larger than intended and harder to review. *Mitigation:* explicit write-scope contracts (§4.2).

**Premature completion.** The agent declares the task done before verifying anything. It has satisfied its own interpretation of the requirements, not the actual acceptance criteria. *Mitigation:* verification gates in ground rules; three-state verdicts (§5.3).

**Context loss.** A session that runs too long or gets compacted loses prior reasoning. Decisions, blockers, and discoveries vanish. *Mitigation:* explicit session state, re-read protocols (§10.2).

**Confabulation.** The agent invents function names, behavioral constraints, and architectural decisions that don’t exist in the codebase. It presents these inventions confidently. *Mitigation:* facts/inferences/unknowns discipline (§10.4); evidence-based scoring; behavior locks (§4.1).

**Poor state recovery.** When a session ends and a new one begins, the agent has no idea what was done. Without state files, every session is a fresh start. *Mitigation:* mandatory file-load order at session start (§10.1).

These are **environmental failures, not model failures.** Rephrasing your prompt doesn’t fix them. Structure does. That’s the harness’s job.

---

## 3. The Four-Layer Inventory

A production-grade harness fits in a small set of files. Not a hundred. Not a framework. A handful, in named layers. The trap most teams fall into is putting the wrong things in the wrong layer, or skipping a layer entirely.

### Layer 1 — Instruction

Standing orders the agent reads at the start of every session.

| Artifact | Purpose |
| --- | --- |
| `AGENTS.md` (or `CLAUDE.md`) | Lean routing file: operating rules, verification gate, session lifecycle, references to deeper docs |
| `docs/agent-rules/*.md` | Domain-specific rule sub-files referenced from the routing file |
| Path-specific instruction files (e.g., `src/auth/AGENTS.md`) | Local rules near risky modules — the agent sees these exactly when it works there |

**Design principle: keep the routing file under ~80 lines.** A 50-rule monolith gets ignored or misapplied. A short routing file with pointers to deeper sources of truth ages well. The size discipline is itself a rule — make it visible in the file’s header.

**Common pitfall:** dumping every conceivable rule into a single 6,000-line `CLAUDE.md`. The model can’t reliably attend to that much, and many of the rules are stale or aspirational. If a line wouldn’t cause a real, repeatable mistake to slip through without it, cut the line.

### Layer 2 — Planning

Documents written before the agent touches code. They constrain the work.

| Artifact | Purpose |
| --- | --- |
| Research document | Compresses *truth* — how the system actually works today. Objective, no opinions, no implementation proposals. |
| Plan document | Compresses *intent* — what the change is, why, and the step-by-step path. Forward-looking. |
| **Behavior lock** | Invariant + proof condition. Names a load-bearing rule and the test that demonstrates it holds. (§4.1) |
| **Write-scope contract** | The explicit list of files each plan step may touch. (§4.2) |

**Design principle: keep research and plan separate.** When research (truth) and plan (intent) live in one document, the agent conflates current state with desired state — treating intended changes as existing behavior, or vice versa. One file per concern.

### Layer 3 — Execution

The capability surface the agent reaches for at runtime.

| Artifact | Purpose |
| --- | --- |
| Skills | Reusable workflow primitives (instructions + reference files + templates) |
| Slash commands | On-demand shortcuts for high-frequency operations |
| Hooks | Deterministic gates: pre-tool-use, post-tool-use, session-start, etc. |
| Subagents | Spawned sub-roles (researcher, implementer, reviewer) with scoped context |
| MCP servers | Runtime access to external tools and services |
| CLI tools | The agent’s hands — `gh`, `git`, `pytest`, `jq`, project-specific scripts |
| Session state / progress log | Where the agent records what it just did and where it is now |

**Design principle: the execution layer is what most teams confuse with the whole harness.** It’s the most *visible* layer (skills are tangible files; ground rules are intangible promises) but it is *one of four*. A repo with 20 skills and no instruction layer is not better-engineered than a repo with one skill and a lean `AGENTS.md`.

### Layer 4 — Evaluation

Sensors that tell you whether work is done correctly.

| Artifact | Purpose |
| --- | --- |
| Deterministic checks | Lint, type-check, tests, SAST, dependency audit, build verification |
| Inferential checks | LLM-as-judge, AI code review, behavioral diff |
| **Three-state verdicts** | Proven · conditionally proven · not proven (§5.3) |
| CI parity | Every local check runs identically in CI |

**Design principle: the evaluation layer is usually the weakest.** Most teams have tests; far fewer have a clear *definition of done* the agent can read. The move that matters: every check is a *named, runnable, gated* operation, and the verdict has three states (not two).

---

## 3.5 What a Minimal Harness Looks Like in a Repo

Concretely, this is one defensible layout for the inventory above. The point isn’t to copy this tree — it’s to see that the artifacts have a home, named layers translate into named folders, and there’s a recognizable place for each piece.

```
your-repo/
├── AGENTS.md / CLAUDE.md              ← Layer 1 (lean routing)
├── docs/
│   ├── agent-rules/                   ← Layer 1 (depth)
│   │   ├── conventions.md
│   │   ├── safety-boundaries.md
│   │   └── verification.md
│   └── architecture/overview.md       (reference doc the agent reads)
├── plans/2026-05-transfer-idempotency/
│   ├── research.md                    ← Layer 2 (truth)
│   ├── plan.md                        ← Layer 2 (intent + write scopes)
│   ├── behavior-locks.md              ← Layer 2 (invariants + proofs)
│   ├── session-state.md               ← Layer 3 (current step)
│   ├── progress.md                    ← Layer 3 (log)
│   └── release-verdict.md             ← Layer 4 (per-change verdict)
├── .claude/                           ← Layer 3 (or .cursor/, .opencode/)
│   ├── skills/<skill-name>/SKILL.md
│   ├── commands/<command>.md
│   └── hooks/<hook>.sh
├── tests/                             ← Layer 4 (deterministic)
├── scripts/validate.sh                ← Layer 4 (unified validation)
└── .github/workflows/ci.yml           ← Layer 4 (CI parity)
```

### Three organizing principles behind this layout

1. **Per-change planning subdirectory.** Everything for one change — research, plan, behavior locks, session state, progress, release verdict — lives in a single `plans/<change-slug>/` folder. A reviewer (or a future agent) opens that one folder and gets the full story of the change. Alternative layouts exist; pick the one your team will actually maintain.
2. **Tool config in its own directory.** Skills, slash commands, hooks, and tool-specific settings live under `.claude/` (or `.cursor/`, `.opencode/`, etc.). This keeps Layer 3 separate from project source code and lets you swap or layer tools without restructuring the repo.
3. **Layer 4 lives wherever your CI does.** Tests, validation scripts, and CI workflow files don’t move to a Layer 4 directory — they live where the rest of your stack expects them. The layer is conceptual; the file locations are conventional.

### Three minimal file examples

Skim these to see what each artifact looks like end-to-end. Each is intentionally minimal — real ones for production work have more, but more isn’t where the leverage lives.

**`AGENTS.md` (lean routing — full file, ~30 lines max):**

```markdown
# Project Agent Rules

Lean routing file. Detail lives in `docs/agent-rules/`.

## What this repo is
A Python FastAPI service for transfer processing. PostgreSQL via pgx.
Tests via pytest. Validation via `scripts/validate.sh`.

## Session lifecycle
At session start, read in order: this file → behavior locks (in the current
plan, if any) → plan.md → session-state.md. Confirm by listing what you read.

## Verification gate
Before declaring done, run `scripts/validate.sh`. All checks must pass.

## Write scope
Touch only files listed in the current plan step. If the current step
requires editing a file not listed, output `SCOPE QUESTION:` and wait.

## Hard stops
-Never modify migration files in `migrations/` without explicit approval.
-Never commit secrets — see `docs/agent-rules/safety-boundaries.md`.
-Never bypass `scripts/validate.sh` (e.g., `--no-verify` on commits).

## Conventions
See `docs/agent-rules/conventions.md` for naming, error handling, SQL style.
```

Note the *checkable rules* discipline: every line above is something the agent can answer yes/no to. *“Be careful”* is not a rule. *“Run `scripts/validate.sh` before declaring done”* is a rule.

**`plans/2026-05-transfer-idempotency/behavior-locks.md` (one entry):**

```markdown
# Behavior Locks — Transfer Idempotency

## Lock 1: Transfers do not double-post

**Invariant:** A submitted transfer with a given idempotency key
produces exactly one row in the transfers table.

**Proof condition:** Submit the same transfer twice (same key,
same body). Verify exactly one row exists in `transfers`; the
second response returns the original record.

**Test coverage:** `tests/integration/transfer_idempotency_test.py::test_duplicate_submission_is_idempotent`

**Source:** PRD §3.2 (idempotency requirement); ADR-0042 (key generation)
```

If the test gets deleted or weakened to pass without enforcing the invariant, the lock is broken. The agent reads this at session start and treats it as a non-negotiable.

**`plans/2026-05-transfer-idempotency/release-verdict.md` (one verdict):**

```markdown
# Release Verdict: transfer-idempotency-key

**Verdict:** Conditionally proven

**Gates:**
-✅ lint, type-check, unit, integration — all pass
-✅ SAST — no findings
-✅ Behavior Lock 1 — proof condition test green

**Must-fix:** None.

**Advisory findings:**
-The new `idempotency_key` column lacks an index. Performance acceptable
  for current load (~100 req/min) but will need indexing if traffic
  doubles. Tracked as TECH-1234.

**Merge recommendation:** Merge; track the advisory finding for follow-up.
```

The three states (*proven*, *conditionally proven*, *not proven*) let the agent surface uncertainty as a first-class outcome. Pass/fail alone would have forced this verdict into a binary — either *“perfect”* or *“failed”* — and neither is true.

---

## 4. The Planning Layer in Depth

The planning layer is where most teams have the biggest gap. Two artifacts deserve dedicated treatment.

### 4.1 Behavior Locks (Invariant + Proof Condition)

A behavior lock pairs an **invariant** (the claim) with a **proof condition** (the operational test that demonstrates it holds), plus a pointer to the existing test that enforces it or an explicit “manually verified” marker if no automated test exists.

**Example:**

```markdown
## Behavior Lock: Transfers do not double-post

**Invariant:** A submitted transfer with a given idempotency key must produce
exactly one record in the transfers table.

**Proof condition:** Submit the same transfer twice (same idempotency key,
same body). Verify exactly one row exists in `transfers` and the second
response returns the original record.

**Test coverage:** `tests/integration/transfer_idempotency_test.py::test_duplicate_submission_is_idempotent`
```

**Why this format works:**

- The invariant is stated in business terms (not in code terms).
- The proof condition is *operational* — anyone can read it and run it.
- The pointer to the test makes it falsifiable: if the test gets deleted, the invariant is no longer enforced and the lock is broken.
- The lock is loaded at session start (along with the plan and constraints). The agent sees it before making any change.

**When to write one:** any time you identify a load-bearing constraint that *must not regress*. Authorization rules. Idempotency guarantees. Audit-trail completeness. Performance budgets that have business meaning. Backwards-compatibility expectations.

**When not to bother:** trivial type contracts (the type system handles them) or stylistic preferences (lint rules handle those). Behavior locks are for the constraints that *aren’t* mechanically caught.

### 4.2 Write-Scope Contracts

A write-scope contract is the explicit list of files a plan step may touch. The agent’s behavior is bound by this contract:

- Touch only files listed in the current step’s scope.
- If the agent needs to touch a file outside the declared scope, surface a *“SCOPE QUESTION”* and wait for human input.
- Never interpret or expand scope independently.

**Example, as part of a plan:**

```markdown
## Step 3: Add idempotency key handling to the transfer endpoint

**Write scope:**
-`src/api/transfer.py`
-`tests/integration/transfer_idempotency_test.py`
-`migrations/2026_05_add_transfer_idempotency_key.sql`

**Out of scope:** anything outside the three files above. If a refactor in an
adjacent module seems required, output "SCOPE QUESTION:" and wait.
```

**Why this works:** it gives the agent an explicit boundary to stay within *and* an explicit escape hatch when the boundary is wrong. The escape hatch is critical — without it, a well-meaning agent will silently expand the scope. With it, the agent surfaces uncertainty instead of papering over it.

**Pairs with:** the *compliance bias* hazard from the Foundations sessions — agents default to silent expansion because completing the task feels like progress. Write-scope contracts make scope expansion a *visible* event.

### 4.3 Research vs. Plan: Separate Truth from Intent

When research (how the system works) and planning (what you’ll change) are combined in a single document, the agent conflates current state with desired state. The fix:

- **`research/<topic>.md`** — compression of truth. Distills how the system actually works. Derived from the code itself. Objective, no opinions.
- **`plan/<change>.md`** — compression of intent. Distills what you’re going to change and why. Forward-looking.

Each document has one job. The research output feeds the plan as input, but they remain separate files.

---

## 5. The Evaluation Layer in Depth

### 5.1 Deterministic Checks (Computational Sensors)

| Check | What it catches | When it gates |
| --- | --- | --- |
| Lint | Style violations, unused imports, simple bugs | Every commit |
| Type-check | Type contract violations | Every commit |
| Unit tests | Logic regressions in isolated units | Every commit |
| Integration tests | Logic regressions across components | Every PR |
| SAST / Semgrep | Security patterns | Every PR |
| Dependency audit | Known vulnerabilities | Every PR + scheduled |
| Build verification | Packaging / compilation | Every PR |

**Design principle: CI parity.** Every check that runs locally runs identically in CI. No more, no less. The agent should be able to assume that *“I ran the local validation command and it passed”* means *“CI will pass.”*

**Design principle: a single unified validation command.** `make check`, `npm run validate`, `uv run validate` — one command that runs the full deterministic suite. The agent should know exactly what to run before declaring done.

### 5.2 Inferential Checks (LLM-as-Judge)

Some quality dimensions don’t reduce to deterministic checks: code clarity, naming consistency, architectural fit, error-handling completeness. For these, an LLM-as-judge can produce useful signal — *if* you treat it as **inferential**, not deterministic.

| Use it for | Don’t use it for |
| --- | --- |
| Code review summaries | Pass/fail merge gates |
| Architectural critique against a documented style | Replacement for type-checking |
| Detecting that a function is doing two things | Anything where false positives have downstream cost |

The cleanest move: an inferential check produces a *narrative output* — findings, suggestions, concerns — that a human reads and decides whether to act on. Don’t wire inferential checks to block merges automatically.

### 5.3 Three-State Verdicts

Most evaluation pipelines have two states: **pass** or **fail**. That’s not enough for agent work.

| Verdict | Meaning | Merge-ready? |
| --- | --- | --- |
| **Proven** | All gates pass. No must-fix findings. Acceptance criteria met. | Yes — merge-ready, release-ready |
| **Conditionally proven** | Gates pass. Advisory findings exist but are accepted with documented rationale. | Yes — merge-ready, follow-up tracked |
| **Not proven** | Must-fix findings present, gate failures, or scope/spec mismatch. | No — return to planning |

**Why the third state matters:** without it, the agent is forced to choose between *“I’m done”* and *“I failed.”* That’s a bad choice for autonomous work — many real changes ship with known caveats, and the choice between *“pretend it’s perfect”* and *“give up”* selects for the wrong behavior. The third state lets the agent *truthfully* surface uncertainty as a first-class outcome.

**The release-verdict artifact** (one per change):

```markdown
## Release Verdict: transfer-idempotency-key

**Verdict:** Conditionally proven

**Gates:** All deterministic checks passed; integration tests added and green.

**Must-fix:** None.

**Advisory findings:**
-The new idempotency key column lacks an index. Performance acceptable for current
  load (~100 req/min) but will need indexing if traffic doubles. Tracked as TECH-1234.

**Merge recommendation:** Merge; track the advisory finding.
```

### 5.4 A Note on LLM Evals

The word *evaluation* in *Layer 4 evaluation* overlaps with *evals* in the LLM research sense, but they operate at different scopes:

|  | LLM evals (research) | Layer 4 evaluation (engineering) |
| --- | --- | --- |
| Question | *How good is this model in general?* | *Is THIS change correct?* |
| Unit of work | Benchmark suites (HumanEval, SWE-bench, MMLU, internal eval sets) | A single PR / change |
| Output | Aggregate scores across many tasks | A verdict on the work in front of you |
| Who reads it | Researchers, model selectors, procurement | The team merging the PR |

They overlap at the **LLM-as-judge** boundary. When an organization builds internal eval suites over its own codebase’s task patterns — *“how well does our agent finish the 100 typical change types we see?”* — those suites start to look like inferential Layer 4 checks aggregated over time. The framing in this guide stays on Layer 4 evaluation (the per-change question) because that’s where the *harness* operates. LLM evals tell you *what your harness has to work around*; Layer 4 tells you *what shipped*.

If a participant asks where to learn more about eval suites, point them outside this guide — there’s a rich research literature, and the right starting points are organization-specific.

---

## 6. Measuring Legibility: The Agentic Legibility Framework

Measuring legibility is the first move of practicing harness engineering on a specific repo. Without the measurement, you’re guessing where to invest; with it, you have a prioritized list of where the agent has to guess. The walkthrough applies the framework end-to-end as the **agentic legibility audit**; this section is the reference, and the rest of the guide goes wider on what to do with the findings.

### The Nine Dimensions

| # | Dimension | Weight | What it asks |
| --- | --- | --- | --- |
| 1 | Repository Orientation | 10% | Can the agent get a high-level map quickly? |
| 2 | Information Findability | 10% | Can the agent locate context for a change without reading the whole repo? |
| 3 | **Codebase Navigability** | **20%** | Can the agent predict what code does before opening it? |
| 4 | Task Executability | 10% | Can the agent set up the environment and run common tasks? |
| 5 | Verification Legibility | 10% | Can the agent tell whether work is done correctly? |
| 6 | **Intent and Invariants** | **15%** | Are the load-bearing rules visible? |
| 7 | Safety Boundaries | 10% | Does the agent know what it can and cannot touch? |
| 8 | Machine-Friendliness | 10% | Are conventions and structured metadata written down? |
| 9 | Freshness and Trustworthiness | 5% | Does the documented state match reality? |

The weighting biases toward whether the agent can safely *complete and verify* work, not just whether documentation exists. That’s why Codebase Navigability (20%) and Intent and Invariants (15%) carry the most weight.

### Cluster Pattern

The walkthrough organizes the 9 dimensions into three clusters: **navigation** (Dim 1, 2, 3 — 40% of the composite), **execution** (Dim 4, 5, 7 — 30%), and **intent** (Dim 6, 8, 9 — 30%). The cluster structure is a useful pacing tool when running the audit — both for the encoded skill (check in between clusters rather than scoring 18 sub-metrics in one go) and for human review (a cluster’s worth of scoring is the right unit for stepping back and challenging fuzzy evidence). The clusters also map to three different *kinds* of agent failure: can it find its way around? can it run and verify? does it know why the code is shaped this way?

### The 0–4 Evidence Rubric

| Score | Meaning |
| --- | --- |
| 0 | Missing or actively hostile to agent execution |
| 1 | Present in fragments, but unreliable or inconsistent |
| 2 | Usable with manual inference and extra exploration |
| 3 | Clear and mostly complete for routine agent work |
| 4 | Explicit, current, machine-friendly, and easy to act on |

**Critical rule: score based on concrete evidence, not inferred intent.** *“Feels descriptive”* is not evidence. A file path is. A grep result is. A config snippet is. The discipline is the trail of evidence behind the score, not the number itself.

### Output Tiers

The composite score maps to one of five tiers:

| Composite | Tier |
| --- | --- |
| 0.0–0.9 | Unaware |
| 1.0–1.9 | Nascent |
| 2.0–2.9 | Structured |
| 3.0–3.5 | Established |
| 3.6–4.0 | Exemplary |

The tier names are useful in conversation (*“this repo is Structured-leaning-Established”*) but the sub-metric scores are where the real signal lives — they tell you *what to fix*, not just *how good you are*.

### N/A Handling

If a sub-metric doesn’t apply (e.g., type-checking in a language without a type system, or generated-vs-editable boundaries in a repo with no generated code), mark it N/A and **exclude it from the dimension average**. Do not redistribute its weight. The framework’s rule is explicit on this.

### Customization

The framework is one defensible cut, not the canonical answer. Three things you should tune:

- **Weights.** If your codebase is safety-critical, bump Safety Boundaries (Dim 7) to 15–20%. If your team is migrating between stacks, bump Verification Legibility.
- **Dimensions.** Drop ones that don’t apply (a CLI tool may not need much Repository Orientation). Add ones that matter for your stack (e.g., a “Schema Evolution Discipline” dimension for data-intensive repos).
- **Evidence.** The default examples lean JS/Python. For your stack, write your own evidence criteria — what does `pytest tests/auth/` look like in Rust (`cargo test --test auth`), .NET (`dotnet test --filter`), Java (`./gradlew test --tests`), or AngularJS (`ng test --include`)?

### The Improvement Backlog Priority

When a repo scores below 3 on several sub-metrics, the framework prescribes this order for remediation:

1. **Make setup and verification runnable from docs** — Dim 4, Dim 5
2. **Add an agent repo map with system boundaries and entrypoints** — Dim 1
3. **Document invariants and risky areas** — Dim 6, Dim 7
4. **Add task runbooks for common changes** — Dim 4.2
5. **Introduce structured metadata that reduces repeated exploration** — Dim 8

Note what’s *not* on the list: documentation freshness, naming conventions. The bet is that **runnability**, **orientation**, **invariants**, **runbooks**, and **metadata** are the high-leverage investments — the others matter but don’t move the score nearly as fast.

---

## 7. The 3-Layer Guardrail Model

A defense-in-depth framing for the harness’s correctness story. Three independent guardrail types operate in parallel:

### Layer 1 — Guidance (Repo-Side Files)

Files that *shape* the agent’s choices before it acts:

- Behavior locks (invariants the agent must preserve)
- Constraints (hard limits the agent must respect)
- Plans (what to do, in what order, with what write scope)
- Ground rules (operating conventions, lifecycle rules)

These are **inferential** in mechanism — the LLM reads them and is influenced — but they’re durable: the same files apply every session.

### Layer 2 — Deterministic (Automated Checks)

Mechanical gates that block every step:

- Lint, type-check, tests, build, SAST, dependency audit
- Pre-tool-use hooks (e.g., block writes to generated files)
- Post-tool-use hooks (e.g., run tests after every edit)
- CI gates that mirror local validation

These are **computational** in mechanism — same input, same output — and unforgiving: they fail loudly on contract violations.

### Layer 3 — Review (Adversarial Critique in a Fresh Session)

A separate evaluator session, with **no chat history from the build phase**, that receives only the artifacts (plan, spec, constraints, behavior locks, implementation) and produces a categorized finding list.

**Why a fresh session?** Self-critique inside the build session is unreliable. The agent’s compliance bias prevents it from genuinely challenging its own work — it has invested in the implementation it just produced. A fresh evaluator session, with no investment, can produce honest critique.

**What this catches that the other two miss:**

- Scope/spec mismatch (the agent shipped what *it* wanted to ship, not what the spec asked for)
- Plausible-but-wrong logic that passes tests because the tests are also wrong
- Missing invariants that weren’t named in behavior locks but should have been
- Compliance bias artifacts — places where the agent silently “improved” something it wasn’t asked to touch

### Why All Three Together

| Layer alone | Failure mode |
| --- | --- |
| Guidance alone | Agent reads the rules but produces non-compliant work; no mechanical or review gate catches it |
| Deterministic alone | Tests pass but the work doesn’t match the spec; nothing reads intent |
| Review alone | Catches issues late, after expensive work has accumulated |

Three together produce confidence that no single layer can produce alone. The cost is real (the review pass adds tokens and latency) but the failure mode of any one layer alone is worse.

---

## 8. Two Disciplines That Keep It Alive

A harness that doesn’t grow gets stale. A harness that never prunes gets bloated. Two disciplines balance each other.

### 8.1 Grow

> *“Anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again.”* — Mitchell Hashimoto, Feb 2026
> 

When the agent makes a mistake, you have a choice: correct it in the conversation, or write a structural fix that prevents the next instance. Conversations are disposable. Structural fixes compound.

**Concrete pattern:** every time you have to correct the agent, ask:

1. Is this a one-off, or will it recur? (If one-off, fix in chat. If recurring, fix structurally.)
2. Which layer would catch it? (Instruction? Planning? Execution? Evaluation?)
3. What’s the smallest structural change that closes the failure mode?

The structural change is usually a single rule in `AGENTS.md`, a single behavior lock in the plan, a single hook, or a single test. Not a rewrite. The smallest fix that closes the failure.

### 8.2 Subtract

As models improve, prune what they no longer need. The instruction line you wrote six months ago for an older model may now be:

- **Dead weight** — the model handles it natively, the rule is just clutter
- **Actively harmful** — the rule steers the agent away from a better default the new model has

**Concrete pattern:** with each model upgrade, re-read the harness and ask:

1. Which rules close failure modes the new model still has? (Keep.)
2. Which rules close failure modes the new model no longer has? (Cut.)
3. Where does the new model expose a new gap the harness doesn’t cover? (Add.)

The interesting work *moves*. It doesn’t shrink.

### 8.3 Continuous Monitoring

Beyond grow/subtract, the harness needs continuous monitoring that runs *outside* the change lifecycle — feeding back to future work, not gating the current change. Two distinct loops, against two different subjects.

### 8.3.1 Continuous drift detection (codebase)

The codebase itself drifts: documentation, configuration, and behavior diverge silently as code moves and the docs don’t.

| Drift signal | Detection |
| --- | --- |
| Stale commands in docs | CI step that runs every command-block in `README.md` |
| Stale architecture docs | Generated architecture index from the dependency graph |
| Stale schema in docs | Schema-doc generation from the source of truth |
| Stale behavior locks | Coverage check: every behavior lock must point at a non-deleted test |
| Dead code | Periodic `/find-dead-code` skill (LLM-as-judge over usage graphs) |
| Unused dependencies | `dependabot` and equivalents flagging unused or out-of-date dependencies |
| Coverage quality | Periodic `/code-coverage-quality` agent run — coverage rate AND meaningfulness |

These don’t catch everything. They catch the most expensive failure mode: docs and structure that confidently describe a system that no longer exists.

### 8.3.2 Continuous runtime feedback (runtime)

The deployed system also produces signal — and the agent can read it. This is the *runtime* counterpart to codebase-drift detection: continuous feedback loops that observe production behavior and surface issues for the next change.

| Runtime signal | Form |
| --- | --- |
| Latency / error rate / availability against SLOs | Computational — direct metric thresholds |
| Span-level performance budgets | Computational — distributed tracing assertions (“no span in this user journey exceeds 2s”) |
| Response quality sampling | Inferential — `/response-quality-sampling` agent over sampled responses |
| Log anomaly detection | Inferential — `/log-anomalies` LLM-as-judge over recent logs |
| Production-vs-staging divergence | Computational — diff of structured metrics |

**A worked example: per-worktree ephemeral observability.** OpenAI’s Codex team describes running a *per-worktree* observability stack — every change boots its own app instance and its own ephemeral Vector → Victoria Logs / Metrics / Traces stack, queried via LogQL / PromQL / TraceQL. The stack is torn down when the task completes. With this in place, prompts like *“ensure service startup completes in under 800ms”* or *“no span in these four critical user journeys exceeds two seconds”* become tractable for the agent — the runtime signal is part of its working context, not a separate concern. This is local-dev observability used as a harness capability, distinct from production observability used for incident response.

**Why split drift from runtime feedback.** They look similar (continuous, outside the change lifecycle, feed forward into future work) but they’re answering different questions. Drift asks *“does the codebase still match its description?”* Runtime feedback asks *“does the running system behave the way the spec said it should?”* A repo can be perfectly drift-free and still ship a latency regression. Treating them as one category loses that distinction.

The split is Böckeler’s; the per-worktree example is OpenAI’s. See §12 for both source pointers.

---

## 9. The L1 → L2 Boundary

The framework can score L1. You make the L2 calls.

### What L1 (Mechanical Readiness) Covers

- Score above threshold on the framework
- Deterministic checks pass
- The agent can navigate the repo, find what it needs, run the workflows, verify its own output
- The harness has all four layers populated

A good toolkit produces L1 automatically. A skill can score it. A hook can enforce it.

### What L2 (Situational Fit) Requires

- Is this the right harness for *this* codebase, *this* team, *this* risk tier?
- Does this particular check earn its compute cost?
- Does this behavior lock capture the right invariant, or a surface symptom?
- Should this skill exist at all, or is it a workaround for something the model can now do natively?
- What’s the *next* improvement to invest in, and why now?

These are L2 questions. No toolkit answers them. You do.

### Why the Toolkit Can’t Cross the Line

The toolkit knows the *structure* of a good harness. It doesn’t know *your* risk tier, *your* team’s tolerance for false positives, *your* codebase’s history. L2 questions require context the toolkit doesn’t have. Pretending the toolkit can answer them produces over-engineered harnesses that nobody trusts.

**The seat in the room is on the L2 side.** Harness engineering doesn’t replace engineers — it moves the work up the abstraction stack. The judgment that used to go into a single implementation now goes into designing the harness that produces dozens of implementations.

---

## 10. Operational Disciplines

These are the moves the in-program session names only in passing. They matter most when the harness gets non-trivial.

### 10.1 Mandatory File-Load Order at Session Start

Don’t let the agent decide what to load *“based on what feels relevant.”* Always load the same fixed set:

1. Instruction file (`AGENTS.md` / `CLAUDE.md`)
2. Behavior locks (if any)
3. Constraints (if any)
4. Plan (if a plan exists for the current change)
5. Session state / progress log (if mid-feature)

Make it an explicit rule in `AGENTS.md`:

> “At the start of every session, before any other action, read in order: this file, `behavior-locks.md`, `constraints.md`, `plan.md`, `session-state.md`. Confirm by listing what you read.”
> 

The discipline ensures the agent sees the load-bearing rules every session, not just when they happen to seem relevant.

### 10.2 `/compact` and `/clear` Re-Read Protocols

After `/compact` (context compression), the agent loses most of the session’s chat history but keeps the system prompt. Critical files may have been mentioned in chat but no longer be in context. The re-read protocol:

> “After `/compact`, before continuing work, re-read: `AGENTS.md`, the current `plan.md`, and `session-state.md`. State the current plan step aloud before any action.”
> 

After `/clear` (full context reset), the agent loses everything. Same protocol, plus the progress log:

> “After `/clear`, the session is fresh. Re-read: `AGENTS.md`, `plan.md`, `progress.md`, `session-state.md`. State the current step aloud before any action.”
> 

Without these protocols, post-compact and post-clear sessions silently lose the load-bearing rules. The agent confidently produces non-compliant work because it forgot the rules existed.

### 10.3 Provenance Discipline

Every implementation constraint must trace back to an explicit upstream source: a PRD line, a design decision, an ADR, a behavior lock, an architectural constraint. The discipline prevents *silent requirement creep* — where the implementer (human or agent) introduces new requirements without traceability.

Concrete pattern: in plan steps and behavior locks, include a *Source* line:

```markdown
**Source:** PRD §3.2 (idempotency requirement); ADR-0042 (key generation strategy)
```

If the agent (or a teammate) needs to verify whether a constraint is still real, they trace it back. Constraints with no source are candidates for removal.

### 10.4 Facts / Inferences / Unknowns Documentation

When documenting an unfamiliar codebase for the agent, explicitly separate three things:

- **Facts** — observed behavior. Verifiable from code or tests.
- **Inferences** — derived guesses. Probable but not verified.
- **Unknowns** — open questions. Things you’d need to ask a human or run an experiment to resolve.

Don’t blur them. A reverse-doc that confidently states *“the auth module uses session cookies”* when in fact it uses both cookies and JWTs (the writer didn’t notice the JWT path) is a worse document than one that says *“observed: session cookies. Open question: is there a JWT path I haven’t found?”*

The discipline pairs with **embedded glossary** documentation — define terms in-line as they appear, so the agent (and the next human reader) is never guessing what *“the auth boundary”* means in this codebase.

---

## 11. Customizing the Framework to Your Context

The framework’s most important feature is its tunability. Three customization moves.

### 11.1 Stack Translation

The framework’s evidence examples lean JS/Python. For your stack, translate the examples once, up front, and reference the translation table during scoring. This is what Step 3 of the walkthrough builds.

Example translations:

| Framework example | Rust | .NET | Java | AngularJS legacy |
| --- | --- | --- | --- | --- |
| `pytest tests/auth/` | `cargo test --test integration_auth` | `dotnet test --filter Category=Auth` | `./gradlew test --tests 'auth.*'` | `ng test --include='**/auth/*.spec.js'` |
| `tsconfig.json strict` | `Cargo.toml` + clippy + `#![deny(warnings)]` | `.editorconfig` + nullable reference types | `build.gradle` + checkstyle + spotbugs | TSLint legacy |
| `package.json build script` | `cargo build --release` | `dotnet build` / msbuild | `./gradlew build` | `npm run build` / gulp |
| `npm audit` | `cargo audit` | `dotnet list package --vulnerable` | `./gradlew dependencyCheckAnalyze` | `npm audit` |
| `.github/workflows/` drift check | Same — also Azure Pipelines, GitLab CI | Same — also Azure Pipelines | Same — also Jenkins | Same — also Jenkins, CircleCI |

The translation table is itself a piece of structured metadata. Keep it in your scorecard or in `docs/`.

### 11.2 Risk-Tier Weighting

The default weights bias toward “the agent can complete and verify work.” Some codebases need different bias:

| Codebase type | Suggested weight adjustment |
| --- | --- |
| Safety-critical (auth, payments, regulated data) | Bump Safety Boundaries (Dim 7) from 10% to 15–20%; bump Intent and Invariants (Dim 6) from 15% to 20% |
| Legacy / brownfield migration | Bump Information Findability (Dim 2) from 10% to 15%; the gap between code and docs is bigger here |
| Greenfield prototype | Drop Documentation Freshness (Dim 9) to N/A; the repo’s too young to have stale docs |
| Open-source library | Bump Documentation Freshness (Dim 9) up to 10%; external users depend on accurate docs |

Don’t tune for tuning’s sake. The default weights are defensible. Tune when you have a real reason.

### 11.3 When to Add or Drop a Dimension

**Add a dimension when:** there’s an aspect of agent-readiness that materially affects your work and isn’t covered by the existing nine. Examples:

- **Schema Evolution Discipline** for data-intensive repos (migration coverage, backwards-compat policies)
- **Multi-Tenancy Boundaries** for SaaS repos
- **API Contract Stability** for repos with external consumers

**Drop a dimension when:** it’s genuinely N/A for your context — not just “low-scoring.” A CLI tool with no test runner might mark Test Discoverability (Dim 5.1) N/A. A library with no setup ceremony (`pip install foo` and you’re done) might mark Setup Reproducibility (Dim 4.1) N/A.

Mark N/A and exclude from the denominator. Don’t redistribute weight to the remaining sub-metrics.

---

## 12. Where to Go Next

### Public Sources

| Source | Why it’s worth reading |
| --- | --- |
| [Cisco AI Harness Toolkit](https://github.com/cisco-open/ai-harness-toolkit) | Open-source (Apache 2.0). The Agentic Legibility Framework’s home. Fork it. |
| [OpenAI Harness Engineering post](https://openai.com/index/harness-engineering/) | Production case study at scale — 1M LOC, ~1,500 PRs, 0 human-written code. |
| Anthropic effective harnesses post | The *subtract* principle in depth. |
| Anthropic harness design for long-running agents | Generator/Evaluator/Planner architecture; pairs with the 3-layer guardrail model. |
| [Böckeler / Fowler — Harness Engineering](https://martinfowler.com/articles/harness-engineering.html) | The 2×2 (Guides/Sensors × Computational/Inferential). Mental model that travels. |
| HumanLayer — “Skill Issue: Harness Engineering” | The *“config problem, not model problem”* framing. |
| OpenAI Symphony | Enterprise-scale harness adoption — what an agent vendor builds when shipping at scale. |
| Thoughtworks SPDD / REASONS Canvas | The provenance discipline in depth. |

### Pattern Library Cross-References

Patterns in this program’s library that align with the harness layers:

| Layer | Patterns |
| --- | --- |
| Instruction | `ground-rules`, `reference-docs`, `context-management` |
| Planning | `behavior-lock`, `write-scope-contract`, `separate-truth-from-intent`, `check-alignment` |
| Execution | `skills`, `agent-shaped-cli`, `hooks`, `subagents-for-context-control`, `harness-profile` |
| Evaluation | `verification-led-development`, `tests-as-contracts`, `feedback-flip`, `plan-based-review` |

### What This Guide Doesn’t Cover

The frontier of harness engineering moves fast. Topics that deserve their own treatment but aren’t deep here:

- **Multi-agent orchestration** — coordinating multiple agents in a planner/executor/evaluator architecture at scale (see OpenAI Symphony, Anthropic harness design for long-running agents)
- **Handoff manifests** — explicit cross-workflow YAML/JSON manifests that chain stages of a larger pipeline
- **Agent-shaped CLIs** — CLI tools designed for agent ergonomics, not just human ergonomics (e.g., machine-readable output modes, idempotent operations)
- **Risk-adjusted autonomy** — matching agent permissions to task risk, formalized as named autonomy levels (covered in the Securing AI-Assisted Development guide)
- **Harness for behavior** vs. **harness for structure** — the open frontier of writing good harnesses for *functional* behavior (Böckeler), where the most interesting unsolved engineering work still sits

The discipline is younger than it feels. Names and patterns are still being settled. The Harness-Driven Delivery session in this program names what’s settled; this guide goes a level deeper; the frontier above is where you go after that.

---

## 13. From Audit to Action — Using Your Scorecard

The audit (§6) produces a prioritized list of remediations. This section is the playbook for working through that list. Each remediation type maps to a specific area of harness practice — with depth in the rest of this guide and (where relevant) in other sessions of the program you’ve already done.

### The cycle

```
   Audit  →  Prioritized findings  →  Apply by type  →  Re-audit
    ↑                                                       ↓
    └───────────────────────────────────────────────────────┘
```

The encoded skill you shipped at the end of the walkthrough makes the audit cheap to re-run. The composite score is your tracking metric over time. Aim to move one cluster by one tier per work-week of investment.

### Mapping remediation types to practice

| Audit finding (scored below 3) | Layer | What to do | Depth in this guide | Adjacent program session |
| --- | --- | --- | --- | --- |
| **Dim 1** Repository Orientation | Instruction | Add an agent repo map; lean `AGENTS.md` routing to `docs/` | §3 Layer 1; §3.5 | Foundations (ground rules) |
| **Dim 2** Information Findability | Instruction + Planning | Colocated module docs, cross-references, change-coupling notes | §3 Layer 1; §4.3 (research vs. plan) | Foundations |
| **Dim 3** Codebase Navigability | (structural — not a harness fix) | Naming, locality of concern, reduce overloaded `common/` and `utils/` buckets | — | Out of scope for harness engineering; treat as a refactor backlog |
| **Dim 4.1** Setup Reproducibility | Execution | Single bootstrap script; idempotent; env vars documented with dev defaults | §3 Layer 3 | Foundations + DPI |
| **Dim 4.2** Task Runbooks | Execution | Repo-specific runbooks for high-frequency changes (slash commands, skills) | §3 Layer 3 | Extend the Agent (skills, slash commands) |
| **Dim 5** Verification Legibility | Evaluation | CI parity, single unified validation command, three-state verdicts, definition of done | §5 (entire) | DPI (verification step) |
| **Dim 6** Intent and Invariants | Planning | **Behavior locks** — invariant + proof condition + test pointer | §4.1 | DPI (planning) |
| **Dim 7** Safety Boundaries | Instruction + Planning | Generated-vs-editable banners, risk-tier annotations, `CODEOWNERS` on sensitive paths | §3 Layer 1; §4.2 (write-scope contracts) | Securing AI-Assisted Development (resource) |
| **Dim 8** Machine-Friendliness | Instruction | Structured metadata: schema docs, interface contracts, module manifests, ownership | §3 Layer 1; §3.5 | — |
| **Dim 9** Freshness and Trustworthiness | Operational | Drift detection in CI; coverage check that every behavior lock points at a non-deleted test | §8.3.1 | — |

Each *adjacent program session* listed above is where you’ve already practiced the operational moves the remediation calls for. The audit just tells you which one your repo most needs.

### The first-week move

If you only have time for **one** remediation: take the top item from your scorecard’s *Highest-Leverage Improvements* section. Apply it. Re-run the encoded audit skill. Watch the composite move.

The Improvement Backlog Priority in §6 prescribes the default order: runnability gates first (Dim 4, 5), repo orientation second (Dim 1), invariants third (Dim 6, 7). Work that order unless your risk tier dictates otherwise (a safety-critical codebase might promote Dim 7 above Dim 1; a brownfield migration might promote Dim 2 above Dim 4).

### When the audit isn’t the right tool

The legibility audit measures *whether the agent can find its way around and verify safely*. It does **not** measure:

- **Code quality.** A test runner that’s wired up and runs cleanly will score Dim 5 well even if the tests cover buggy logic. The audit doesn’t read your tests’ assertions.
- **Refactor needs.** Seams, tight coupling, missing characterization tests, modules that have grown into god-objects — these are real harness-adjacent problems but the legibility framework doesn’t surface them directly. **If your audit surfaced lots of Dim 5 and Dim 6 findings, the *Canary + SLIM* session in this program is the next stop** — it goes deeper on characterization tests, seam discovery, and structured refactor patterns that pair with the legibility work.
- **Spec quality.** Whether the right thing is being built — the agent’s interpretation of intent, scope creep at the spec level. That’s *DPI* (Design, Plan, Implement) territory; the audit assumes the spec is upstream of it.

If your audit scores high but the agent still produces bad work, the answer is one of these adjacent disciplines, not “score higher on Dim N.”

### Capturing the invariants surfaced by Step 6

Step 6 of the walkthrough surfaces *candidate behavior locks* — invariants that exist in code but aren’t documented anywhere. Each one is a candidate planning-layer artifact (§4.1):

1. Name the invariant in business terms (“only admins may approve transfers”), not in code terms.
2. Pair it with a proof condition (the operational test that fails if the invariant breaks).
3. Add it to `plans/<change>/behavior-locks.md` so the agent reads it at session start (§10.1).

A repo with documented behavior locks for its load-bearing invariants will score Dim 6.2 at 3–4 next time. **Behavior locks are the single highest-leverage operational follow-up the audit produces** — they’re cheap to write (10–30 minutes each), they compound (each new contributor reads them), and they catch the failure mode the audit’s other dimensions don’t reach: *the agent produced wrong work that passed the tests because the tests didn’t enforce the invariant.*

### Closing the loop

The point of the encoded skill is that re-auditing is cheap. After each meaningful change to the harness, re-run the audit on the same repo and diff the scorecard. If the score moved, you have evidence the change was worth shipping. If it didn’t move, you have a candidate for the *Subtract* discipline (§8.2) — a rule that didn’t earn its keep.

The composite score isn’t the point. The composite score moving over time, with each sub-metric improvement traceable to a specific harness change you made, is the point.

---

*Harness engineering is a peer discipline. A production-grade harness is small. The framework is one defensible cut, not the answer.*