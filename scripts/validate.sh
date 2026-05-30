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
