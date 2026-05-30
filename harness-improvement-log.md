# Harness Improvement Log

> Append-only. Each entry records a gap found, what was changed, and why it matters.
> Update this file whenever a harness improvement is made during any session.

---

## 2026-05-30 — Session state files were never written during execution

**Gap found:** `CLAUDE.md` told agents to *read* `session-state.md` and `progress.md` at session start, but never told them to *write* those files during or after a session. Both files were missing entirely for the active feature, so there was nothing useful to read on resume.

**What changed:**
- Added "Session updates" rule to `CLAUDE.md` requiring `session-state.md` to be updated after each task (not just at session end), and `progress.md` to be appended to before closing.
- Created `session-state.md` and `progress.md` for the active feature (`docs/designs/2026-05-29-example-todo-app/`) with proper content.

**Why it matters:** Without these files, resuming a session requires the user to re-explain current state. With them, the agent reads the files at startup and picks up exactly where it left off.

---

## 2026-05-30 — No automated prompt to update session state at session end

**Gap found:** Agents had no mechanism to detect that a session was ending. The write rule added above relied on agent discipline — easy to skip under time pressure or mid-interruption.

**What changed:**
- Created `.claude/settings.json` with a `Stop` hook that detects active "In progress" features (by scanning `docs/designs/*/session-state.md`) and shows a `systemMessage` reminding the user to ask Claude to update `session-state.md` and `progress.md` before closing.
- Hook is project-scoped so it only fires in repos with this harness, not in unrelated projects.

**Why it matters:** Makes session state updates the path of least resistance — the UI prompts the user rather than relying on memory.

---

## 2026-05-30 — No root .gitignore; worktrees and local settings were untracked noise

**Gap found:** The repo had no root `.gitignore`. The `.claude/worktrees/` directory (which contains full git worktree checkouts including node_modules) and `.claude/settings.local.json` (personal overrides) showed up as untracked files on every `git status`, creating noise and risk of accidental commits.

**What changed:**
- Created `.gitignore` at repo root ignoring `.claude/worktrees/` and `.claude/settings.local.json`.

**Why it matters:** Without this, every developer who uses worktrees or local settings will see noisy `git status` output and risks accidentally staging those directories.

---

## 2026-05-30 — Harness improvement log itself was missing

**Gap found:** Harness tweaks were being made but not recorded anywhere. Lessons learned in one session (e.g. "session-state needs to be written, not just read") were invisible to future sessions and to anyone using this repo as a template.

**What changed:**
- Created this file (`harness-improvement-log.md`) at repo root.
- Added a rule to `CLAUDE.md` requiring this log to be updated whenever a harness improvement is made.

**Why it matters:** The harness is only useful as a template if the improvements made while dogfooding it are captured and carried forward.
