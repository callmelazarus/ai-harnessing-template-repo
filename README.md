# AI Harnessing Template Repo

A four-layer AI coding harness for TypeScript/JavaScript projects. Use it as a starting template for new repos, or install its commands globally to initialize and audit any project.

---

## What is a harness?

A harness is the runtime environment you build around an AI coding agent. The model is the LLM — the harness is everything else: the rules it reads, the plans it follows, the verification gates it must pass, and the commands available to it.

Without a harness, capable models still drift scope, declare tasks done prematurely, and lose context between sessions. The harness fixes these with structure, not prompts.

This repo implements a **four-layer harness**:

| Layer | What it does | Files |
|---|---|---|
| **1 — Instruction** | Standing orders the agent reads at session start | `CLAUDE.md`, `docs/agent-rules/` |
| **2 — Planning** | Per-feature research, intent, invariants, and state | `plans/`, `plans/_template/` |
| **3 — Execution** | Slash commands for managing the harness | `.claude/commands/` |
| **4 — Evaluation** | Verification gate and CI parity | `scripts/validate.sh`, `.github/workflows/ci.yml` |

---

## How to use this repo

### Option A — Global commands (recommended)

Install the harness commands globally so they're available in any Claude Code session on your machine:

```bash
mkdir -p ~/.claude/commands
ln -s /path/to/this-repo/.claude/commands/harness-audit.md ~/.claude/commands/harness-audit.md
ln -s /path/to/this-repo/.claude/commands/harness-init.md ~/.claude/commands/harness-init.md
```

Replace `/path/to/this-repo` with the actual path where you cloned this repo.

Using symlinks (not copies) means any improvements you make to the commands here propagate automatically to all future sessions.

**Then, for any new project:**

1. Open the project in Claude Code
2. Type `/harness-init`
3. Answer two questions (what's the repo for? what stack?)
4. Claude creates all the harness files tailored to your project

### Option B — Clone as a template

Clone this repo as the starting point for a new project and adapt the files directly.

---

## Commands

Once installed globally, two slash commands are available in any Claude Code session:

### `/harness-init`

Initializes a harness in the current repository. Asks for the repo's purpose and stack, then creates:

- `CLAUDE.md` — lean routing file with session rules
- `docs/agent-rules/` — conventions, safety boundaries, definition of done
- `plans/` — planning directory with `_template/` for new features
- `scripts/validate.sh` — unified validation entry point
- `.github/workflows/ci.yml` — CI that runs the same validation

### `/harness-audit`

Scores the current repository against the [Agentic Legibility Framework](docs/resources/hardness-engineering-guide.md) — a 9-dimension rubric measuring how well an agent can navigate, execute, and understand the codebase. Outputs a composite score, a tier (Unaware → Exemplary), and a prioritized improvement backlog.

---

## Working on a feature

Each feature or change gets its own plan directory:

```
plans/
└── 2026-05-auth-middleware/
    ├── research.md       ← how the system works today
    ├── plan.md           ← what changes, step-by-step, with write-scope contracts
    ├── behavior-locks.md ← invariants that must not regress
    ├── session-state.md  ← current step (updated each session)
    ├── progress.md       ← append-only log
    └── release-verdict.md ← proven / conditionally proven / not proven
```

Copy `plans/_template/` to start a new plan. The agent reads the active plan at session start and stays within each step's declared write scope.

---

## Reference material

- [`docs/resources/hardness-engineering-guide.md`](docs/resources/hardness-engineering-guide.md) — full practitioner's guide to harness engineering
- [`docs/resources/cisco-open-ai-harness-toolkit.md`](docs/resources/cisco-open-ai-harness-toolkit.md) — Cisco open-source harness toolkit
