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
