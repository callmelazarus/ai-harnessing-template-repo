# Example Todo App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a working Next.js 15 + Drizzle + SQLite todo app in `example/` to dogfood the harness.

**Architecture:** Self-contained Next.js 15 App Router app in `example/` with its own `package.json`. Server Actions handle mutations; a pure query layer (`src/db/queries.ts`) is tested with vitest against an in-memory SQLite DB. The harness `validate.sh` is extended to typecheck and build the example app.

**Tech Stack:** Next.js 15, React 19, TypeScript 5, Drizzle ORM, better-sqlite3, TailwindCSS v4, vitest

---

## File Map

| File | Responsibility |
|---|---|
| `example/package.json` | Dependencies and scripts |
| `example/tsconfig.json` | TypeScript config |
| `example/next.config.ts` | Next.js config (marks better-sqlite3 as external) |
| `example/postcss.config.mjs` | TailwindCSS v4 PostCSS plugin |
| `example/vitest.config.ts` | Vitest test runner config |
| `example/drizzle.config.ts` | Drizzle Kit config for migrations |
| `example/.gitignore` | Ignores todos.db and .next/ |
| `example/src/db/schema.ts` | Drizzle table definition and exported types |
| `example/src/db/index.ts` | better-sqlite3 singleton connection |
| `example/src/db/queries.ts` | Pure query functions (testable, no Server Action coupling) |
| `example/src/db/queries.test.ts` | Vitest integration tests against in-memory SQLite |
| `example/src/app/actions.ts` | Next.js Server Actions wrapping query functions |
| `example/src/app/globals.css` | Tailwind import |
| `example/src/app/layout.tsx` | Root layout |
| `example/src/app/page.tsx` | Home page — Server Component, fetches todos |
| `example/src/components/add-todo-form.tsx` | Client Component — controlled input + submit |
| `example/src/components/todo-list.tsx` | Server Component — renders list |
| `example/src/components/todo-item.tsx` | Client Component — checkbox + delete |
| `scripts/validate.sh` | Extended to typecheck + build example/ |

---

### Task 1: Scaffold the project

**Files:**
- Create: `example/package.json`
- Create: `example/tsconfig.json`
- Create: `example/next.config.ts`
- Create: `example/postcss.config.mjs`
- Create: `example/vitest.config.ts`
- Create: `example/.gitignore`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "example-todo",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:setup": "drizzle-kit generate && drizzle-kit migrate"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "better-sqlite3": "^11.0.0",
    "drizzle-orm": "^0.41.0"
  },
  "devDependencies": {
    "@tailwindcss/postcss": "^4.0.0",
    "@types/better-sqlite3": "^7.6.0",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "drizzle-kit": "^0.30.0",
    "tailwindcss": "^4.0.0",
    "typescript": "^5.0.0",
    "vitest": "^3.0.0"
  }
}
```

- [ ] **Step 2: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

- [ ] **Step 3: Create next.config.ts**

```typescript
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  serverExternalPackages: ['better-sqlite3'],
}

export default nextConfig
```

- [ ] **Step 4: Create postcss.config.mjs**

```js
const config = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}

export default config
```

- [ ] **Step 5: Create vitest.config.ts**

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
  },
})
```

- [ ] **Step 6: Create .gitignore**

```
.next/
node_modules/
todos.db
```

- [ ] **Step 7: Install dependencies**

Run from `example/`:
```bash
npm install
```

Expected: `node_modules/` created, `package-lock.json` written.

- [ ] **Step 8: Commit**

```bash
git add example/
git commit -m "chore: scaffold example Next.js todo app"
```

---

### Task 2: DB schema, connection, and migrations

**Files:**
- Create: `example/src/db/schema.ts`
- Create: `example/src/db/index.ts`
- Create: `example/drizzle.config.ts`

- [ ] **Step 1: Create src/db/schema.ts**

```typescript
import { integer, sqliteTable, text } from 'drizzle-orm/sqlite-core'

export const todos = sqliteTable('todos', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  text: text('text').notNull(),
  completed: integer('completed', { mode: 'boolean' }).notNull().default(false),
  createdAt: integer('created_at', { mode: 'timestamp' })
    .notNull()
    .$defaultFn(() => new Date()),
})

export type Todo = typeof todos.$inferSelect
export type NewTodo = typeof todos.$inferInsert
```

- [ ] **Step 2: Create drizzle.config.ts**

```typescript
import type { Config } from 'drizzle-kit'

export default {
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'sqlite',
  dbCredentials: {
    url: './todos.db',
  },
} satisfies Config
```

- [ ] **Step 3: Generate migration files**

Run from `example/`:
```bash
npm run db:generate
```

Expected: `example/drizzle/` directory created with a `0000_*.sql` migration file.

- [ ] **Step 4: Apply migrations (creates todos.db)**

Run from `example/`:
```bash
npm run db:migrate
```

Expected: `example/todos.db` created with the `todos` table.

- [ ] **Step 5: Create src/db/index.ts**

```typescript
import Database from 'better-sqlite3'
import { drizzle } from 'drizzle-orm/better-sqlite3'
import * as schema from './schema'

const sqlite = new Database(process.env.DATABASE_PATH ?? 'todos.db')
export const db = drizzle(sqlite, { schema })
export type Db = typeof db
```

- [ ] **Step 6: Commit**

```bash
git add example/src/db/ example/drizzle.config.ts example/drizzle/
git commit -m "feat: add Drizzle schema, DB connection, and migrations"
```

---

### Task 3: Query functions (TDD)

**Files:**
- Create: `example/src/db/queries.test.ts`
- Create: `example/src/db/queries.ts`

- [ ] **Step 1: Write the failing tests**

Create `example/src/db/queries.test.ts`:

```typescript
import { beforeEach, describe, expect, it } from 'vitest'
import Database from 'better-sqlite3'
import { drizzle } from 'drizzle-orm/better-sqlite3'
import { migrate } from 'drizzle-orm/better-sqlite3/migrator'
import type { BetterSQLite3Database } from 'drizzle-orm/better-sqlite3'
import * as schema from './schema'
import {
  createTodoQuery,
  deleteTodoQuery,
  getTodosQuery,
  toggleTodoQuery,
} from './queries'

let db: BetterSQLite3Database<typeof schema>

beforeEach(() => {
  const sqlite = new Database(':memory:')
  db = drizzle(sqlite, { schema })
  migrate(db, { migrationsFolder: './drizzle' })
})

describe('getTodosQuery', () => {
  it('returns empty array when no todos exist', () => {
    expect(getTodosQuery(db)).toEqual([])
  })

  it('returns todos ordered newest first', () => {
    db.insert(schema.todos).values([
      { text: 'first', createdAt: new Date(1000) },
      { text: 'second', createdAt: new Date(2000) },
    ])
    const result = getTodosQuery(db)
    expect(result[0].text).toBe('second')
    expect(result[1].text).toBe('first')
  })
})

describe('createTodoQuery', () => {
  it('inserts a todo and returns success', () => {
    const result = createTodoQuery(db, 'buy milk')
    expect(result).toEqual({ success: true })
    expect(getTodosQuery(db)).toHaveLength(1)
    expect(getTodosQuery(db)[0].text).toBe('buy milk')
  })

  it('trims whitespace from text', () => {
    createTodoQuery(db, '  walk dog  ')
    expect(getTodosQuery(db)[0].text).toBe('walk dog')
  })

  it('returns error when text is blank', () => {
    const result = createTodoQuery(db, '   ')
    expect(result).toEqual({ error: 'Text is required' })
    expect(getTodosQuery(db)).toHaveLength(0)
  })
})

describe('toggleTodoQuery', () => {
  it('sets completed to true on first toggle', () => {
    createTodoQuery(db, 'test')
    const [todo] = getTodosQuery(db)
    toggleTodoQuery(db, todo.id)
    expect(getTodosQuery(db)[0].completed).toBe(true)
  })

  it('sets completed back to false on second toggle', () => {
    createTodoQuery(db, 'test')
    const [todo] = getTodosQuery(db)
    toggleTodoQuery(db, todo.id)
    toggleTodoQuery(db, todo.id)
    expect(getTodosQuery(db)[0].completed).toBe(false)
  })

  it('returns success', () => {
    createTodoQuery(db, 'test')
    const [todo] = getTodosQuery(db)
    expect(toggleTodoQuery(db, todo.id)).toEqual({ success: true })
  })

  it('returns error when todo not found', () => {
    expect(toggleTodoQuery(db, 999)).toEqual({ error: 'Todo not found' })
  })
})

describe('deleteTodoQuery', () => {
  it('removes the todo and returns success', () => {
    createTodoQuery(db, 'to delete')
    const [todo] = getTodosQuery(db)
    const result = deleteTodoQuery(db, todo.id)
    expect(result).toEqual({ success: true })
    expect(getTodosQuery(db)).toHaveLength(0)
  })

  it('returns success even when id does not exist', () => {
    expect(deleteTodoQuery(db, 999)).toEqual({ success: true })
  })
})
```

- [ ] **Step 2: Run tests — verify they fail**

Run from `example/`:
```bash
npm test
```

Expected: FAIL — `Cannot find module './queries'`

- [ ] **Step 3: Implement queries.ts**

Create `example/src/db/queries.ts`:

```typescript
import { desc, eq } from 'drizzle-orm'
import { todos } from './schema'
import type { Db } from './index'

type Result = { success: true } | { error: string }

export function getTodosQuery(db: Db) {
  return db.select().from(todos).orderBy(desc(todos.createdAt))
}

export function createTodoQuery(db: Db, text: string): Result {
  const trimmed = text.trim()
  if (!trimmed) return { error: 'Text is required' }
  db.insert(todos).values({ text: trimmed })
  return { success: true }
}

export function toggleTodoQuery(db: Db, id: number): Result {
  const [todo] = db.select().from(todos).where(eq(todos.id, id))
  if (!todo) return { error: 'Todo not found' }
  db.update(todos).set({ completed: !todo.completed }).where(eq(todos.id, id))
  return { success: true }
}

export function deleteTodoQuery(db: Db, id: number): Result {
  db.delete(todos).where(eq(todos.id, id))
  return { success: true }
}
```

- [ ] **Step 4: Run tests — verify they pass**

Run from `example/`:
```bash
npm test
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add example/src/db/queries.ts example/src/db/queries.test.ts
git commit -m "feat: add query functions with integration tests"
```

---

### Task 4: Server Actions

**Files:**
- Create: `example/src/app/actions.ts`

- [ ] **Step 1: Create actions.ts**

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { db } from '../db/index'
import { createTodoQuery, deleteTodoQuery, toggleTodoQuery } from '../db/queries'

export async function createTodo(text: string) {
  const result = createTodoQuery(db, text)
  if ('success' in result) revalidatePath('/')
  return result
}

export async function toggleTodo(id: number) {
  const result = toggleTodoQuery(db, id)
  if ('success' in result) revalidatePath('/')
  return result
}

export async function deleteTodo(id: number) {
  const result = deleteTodoQuery(db, id)
  if ('success' in result) revalidatePath('/')
  return result
}
```

- [ ] **Step 2: Commit**

```bash
git add example/src/app/actions.ts
git commit -m "feat: add Server Actions for todo mutations"
```

---

### Task 5: UI components and layout

**Files:**
- Create: `example/src/app/globals.css`
- Create: `example/src/app/layout.tsx`
- Create: `example/src/components/add-todo-form.tsx`
- Create: `example/src/components/todo-list.tsx`
- Create: `example/src/components/todo-item.tsx`

- [ ] **Step 1: Create globals.css**

```css
@import "tailwindcss";
```

- [ ] **Step 2: Create layout.tsx**

```tsx
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Todo App',
  description: 'Example harness todo app',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 min-h-screen">
        {children}
      </body>
    </html>
  )
}
```

- [ ] **Step 3: Create add-todo-form.tsx**

```tsx
'use client'

import { useState, useTransition } from 'react'
import { createTodo } from '../app/actions'

export function AddTodoForm() {
  const [text, setText] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isPending, startTransition] = useTransition()

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!text.trim()) return
    startTransition(async () => {
      const result = await createTodo(text)
      if ('error' in result) {
        setError(result.error)
      } else {
        setText('')
        setError(null)
      }
    })
  }

  return (
    <form onSubmit={handleSubmit} className="flex gap-2 mb-6">
      <input
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="What needs doing?"
        disabled={isPending}
        className="flex-1 border rounded px-3 py-2 bg-white"
      />
      <button
        type="submit"
        disabled={isPending || !text.trim()}
        className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 disabled:opacity-50"
      >
        Add
      </button>
      {error && <span className="text-red-500 text-sm self-center">{error}</span>}
    </form>
  )
}
```

- [ ] **Step 4: Create todo-item.tsx**

```tsx
'use client'

import { useState, useTransition } from 'react'
import { deleteTodo, toggleTodo } from '../app/actions'
import type { Todo } from '../db/schema'

export function TodoItem({ todo }: { todo: Todo }) {
  const [isPending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  function handleToggle() {
    startTransition(async () => {
      const result = await toggleTodo(todo.id)
      if ('error' in result) setError(result.error)
    })
  }

  function handleDelete() {
    startTransition(async () => {
      const result = await deleteTodo(todo.id)
      if ('error' in result) setError(result.error)
    })
  }

  return (
    <li className="flex items-center gap-3 py-3">
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={handleToggle}
        disabled={isPending}
        className="h-4 w-4 cursor-pointer"
      />
      <span className={`flex-1 ${todo.completed ? 'line-through text-gray-400' : ''}`}>
        {todo.text}
      </span>
      <button
        onClick={handleDelete}
        disabled={isPending}
        className="text-red-400 hover:text-red-600 disabled:opacity-50 text-sm"
      >
        Delete
      </button>
      {error && <span className="text-red-500 text-xs">{error}</span>}
    </li>
  )
}
```

- [ ] **Step 5: Create todo-list.tsx**

```tsx
import { TodoItem } from './todo-item'
import type { Todo } from '../db/schema'

export function TodoList({ todos }: { todos: Todo[] }) {
  if (todos.length === 0) {
    return <p className="text-gray-400 text-sm">No todos yet — add one above.</p>
  }

  return (
    <ul className="divide-y divide-gray-100">
      {todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} />
      ))}
    </ul>
  )
}
```

- [ ] **Step 6: Commit**

```bash
git add example/src/app/globals.css example/src/app/layout.tsx example/src/components/
git commit -m "feat: add UI components and layout"
```

---

### Task 6: Wire up the page and verify

**Files:**
- Create: `example/src/app/page.tsx`

- [ ] **Step 1: Create page.tsx**

```tsx
import { db } from '../db/index'
import { getTodosQuery } from '../db/queries'
import { AddTodoForm } from '../components/add-todo-form'
import { TodoList } from '../components/todo-list'

export default function Home() {
  const todos = getTodosQuery(db)

  return (
    <main className="max-w-xl mx-auto py-10 px-4">
      <h1 className="text-2xl font-bold mb-6">Todos</h1>
      <AddTodoForm />
      <TodoList todos={todos} />
    </main>
  )
}
```

- [ ] **Step 2: Run typecheck**

Run from `example/`:
```bash
npm run typecheck
```

Expected: No errors.

- [ ] **Step 3: Run build**

Run from `example/`:
```bash
npm run build
```

Expected: Build succeeds. `.next/` directory created.

- [ ] **Step 4: Smoke-test in the browser**

Run from `example/`:
```bash
npm run dev
```

Open `http://localhost:3000`. Verify:
- Page loads with an empty list and the input form
- Typing a todo and clicking Add creates it in the list
- Clicking the checkbox toggles strikethrough
- Clicking Delete removes the todo
- Refresh keeps todos (persisted in SQLite)

Stop the dev server with `Ctrl+C`.

- [ ] **Step 5: Commit**

```bash
git add example/src/app/page.tsx
git commit -m "feat: wire up todo page — app is functional"
```

---

### Task 7: Extend validate.sh

**Files:**
- Modify: `scripts/validate.sh`

- [ ] **Step 1: Add example/ checks to validate.sh**

Replace the contents of `scripts/validate.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Unified validation script — the single source of truth for "done".
# CI runs this same script. Add no extra steps to CI that don't run locally.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ ! -f "package.json" ]; then
  echo "No root package.json — skipping root JS/TS checks."
else
  echo "=== Root: Type check ==="
  npx tsc --noEmit

  echo "=== Root: Lint ==="
  npx eslint .

  echo "=== Root: Tests ==="
  npx jest --passWithNoTests

  echo "=== Root: Build ==="
  npm run build --if-present
fi

if [ -d "example" ]; then
  echo ""
  echo "=== example/: Type check ==="
  npm run typecheck --prefix example

  echo "=== example/: Tests ==="
  npm test --prefix example

  echo "=== example/: Build ==="
  npm run build --prefix example
fi

echo ""
echo "=== All checks passed ==="
```

- [ ] **Step 2: Run validate.sh — verify it passes**

Run from repo root:
```bash
bash scripts/validate.sh
```

Expected output includes:
```
=== example/: Type check ===
=== example/: Tests ===
=== example/: Build ===
=== All checks passed ===
```

- [ ] **Step 3: Commit**

```bash
git add scripts/validate.sh
git commit -m "feat: extend validate.sh to cover example/ app"
```
