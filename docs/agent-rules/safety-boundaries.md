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
