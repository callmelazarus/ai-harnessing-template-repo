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
- **Hard stops:** never bypass validate.sh; never modify docs/designs/_template/ without approval; never commit secrets
- **References:** docs/agent-rules/ for conventions, safety, verification

Keep it under 80 lines.

### 3. Create docs/agent-rules/

Create `docs/agent-rules/` with three files:

**conventions.md** — naming, imports, error handling, file structure, commit style for the identified stack:
- TypeScript: camelCase vars/fns, PascalCase types, explicit return types, no `any`, co-located tests
- Python: snake_case vars/fns, PascalCase classes, type hints on all public functions, pytest tests beside source
- Other stacks: ask the user for the key conventions

**safety-boundaries.md** — standard content (docs/designs/_template/ locked, CI locked, no secrets, scope discipline)

**verification.md** — standard content (definition of done, three-state verdicts, verification sequence, post-compact protocol)

### 4. Create docs/designs/ structure

Create `docs/designs/README.md` (standard content: naming, files table, session start protocol, don't delete after merge).

Create `docs/designs/_template/` with these seven files (use standard template content):
- design.md, research.md, plan.md, behavior-locks.md, session-state.md, progress.md, release-verdict.md

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
