# Example Todo App — Design Spec

**Date:** 2026-05-29
**Status:** Approved

## Purpose

A real, working todo list app built in `example/` as a self-contained subtree. Primary goal is to dogfood the four-layer harness: build something real with it, surface friction, and refactor the harness until it works the way it should.

---

## Architecture

Self-contained Next.js 15 App Router app at `example/` with its own `package.json`. No shared dependencies with the root harness repo.

**Stack:**
- Next.js 15 (App Router, TypeScript)
- Drizzle ORM + better-sqlite3
- TailwindCSS v4
- SQLite file at `example/todos.db` (gitignored)

The harness wraps it at the root level: `scripts/validate.sh` is extended to run `cd example && npm run build && npm run typecheck`. The implementation plan lives in `plans/2026-05-example-todo-app/` as a normal harness plan.

---

## File Structure

```
example/
├── package.json
├── tsconfig.json
├── next.config.ts
├── drizzle.config.ts
├── src/
│   ├── app/
│   │   ├── layout.tsx          ← root layout, Tailwind globals
│   │   ├── page.tsx            ← todo list page (Server Component)
│   │   └── actions.ts          ← Server Actions: create, toggle, delete
│   ├── db/
│   │   ├── schema.ts           ← Drizzle table definition
│   │   └── index.ts            ← DB singleton (better-sqlite3 connection)
│   └── components/
│       ├── todo-list.tsx       ← renders list of todos
│       ├── todo-item.tsx       ← single todo row (checkbox + delete)
│       └── add-todo-form.tsx   ← controlled input + submit
└── drizzle/
    └── migrations/             ← generated migration files
```

`todos.db` is created at runtime and gitignored. No environment variables required — `npm run dev` from `example/` is the full local setup.

---

## Data Model

Single `todos` table:

```typescript
// src/db/schema.ts
export const todos = sqliteTable('todos', {
  id:        integer('id').primaryKey({ autoIncrement: true }),
  text:      text('text').notNull(),
  completed: integer('completed', { mode: 'boolean' }).notNull().default(false),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull()
             .$defaultFn(() => new Date()),
})
```

**Four operations:**
- `getTodos()` — select all, ordered by `created_at` desc (called from Server Component directly, not a Server Action)
- `createTodo(text: string)` — insert
- `toggleTodo(id: number)` — flip `completed`
- `deleteTodo(id: number)` — delete by id

No soft deletes, no user accounts, no categories.

---

## Components and Data Flow

`page.tsx` is a Server Component that calls `getTodos()` directly and passes results down. No client-side fetching, no loading states for the initial render.

```
page.tsx (Server Component)
  └── <AddTodoForm />   (Client Component — needs controlled input)
  └── <TodoList />      (Server Component — receives todos as props)
        └── <TodoItem /> × n  (Client Component — checkbox and delete trigger actions)
```

`AddTodoForm` calls `createTodo` on submit and clears the input; Next.js revalidates the page. `TodoItem` calls `toggleTodo` or `deleteTodo` on interaction — same revalidation pattern. No optimistic UI; the localhost round-trip is fast enough.

---

## Error Handling

Server Actions wrap DB calls in try/catch and return `{ error: string } | { success: true }`. Components surface errors inline without crashing the page. Empty `text` input is rejected client-side before the action fires.

---

## Testing

One `vitest` integration test file at `src/app/actions.test.ts`. Spins up an in-memory SQLite DB, runs each action, and asserts the result. No component rendering tests — the harness `validate.sh` gate covers type safety and build correctness; the integration tests cover the data layer.

`npm test` runs via vitest.

---

## Harness Integration Points

| Layer | What changes |
|---|---|
| **1 — Instruction** | Root `CLAUDE.md` unchanged; `example/` follows root conventions |
| **2 — Planning** | Implementation plan at `plans/2026-05-example-todo-app/` |
| **3 — Execution** | No new commands needed |
| **4 — Evaluation** | `scripts/validate.sh` extended to typecheck + build `example/` |
