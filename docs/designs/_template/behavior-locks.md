# Behavior Locks: [Feature Name]

> Read this file at every session start. These invariants are non-negotiable.
> Each lock: a business-terms invariant, a proof condition, and the test that enforces it.

## Lock 1: [Name]

**Invariant:** [State the constraint in business terms, not code terms]

**Proof condition:** [What you would do to verify this holds — readable by anyone]

**Test coverage:** `tests/path/to/test.ts::testName`
(or "manually verified — no automated test" if none exists)

**Source:** [PRD section, ADR, or architectural decision that established this constraint]
