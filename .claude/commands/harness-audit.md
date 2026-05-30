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
