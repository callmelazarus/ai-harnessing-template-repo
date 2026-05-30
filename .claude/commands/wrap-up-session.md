# Wrap Up Session

Generate a concise, copy-pasteable prompt that lets a fresh Claude session continue your work. The prompt references plan files (doesn't duplicate them), includes git state, and clearly states what's done vs. remaining.

**Core principle:** Handoff prompts are pointers, not documentation. The next session reads the docs — you just tell them where to look.

## Process

**Step 1: Gather state**
- Check for plan file: `docs/plans/*.md` or `docs/superpowers/plans/*.md`
- Read plan if exists: what's done vs. remaining (task numbers only)
- Note DESIGN.md or equivalent spec location if present

**Step 2: Check git**
- Current branch: `git branch --show-current`
- Recent commits (last 3-5): `git log --oneline -5`
- Working tree status: `git status --short`

**Step 3: Generate prompt using this template**

```
Continuing work on [project-name].

[If mid-task:]
Current session stopped mid-work on [brief task description].

Plan: [path/to/plan-file] - [X of Y tasks complete]
Completed: [task numbers only, e.g. "Tasks 1-3"]
Remaining: [task numbers only, e.g. "Tasks 4-5"]

[If work complete:]
Previous session completed [brief description].
Plan: [path/to/plan-file] - all tasks complete ✅

Git context:
- Branch: [branch-name]
- Recent commits: [last 3 commits, one-line each]
- Working tree: [clean | uncommitted changes in: file1, file2]

Before starting: review [spec/plan file] to understand current state, then [what to do next].
```

**Step 4: Present the prompt**

Say: "Here's your handoff prompt for the next session:" followed by the copyable text block.

## Rules

- Pointers, not details — the next session reads the docs, don't duplicate them
- Task numbers only, not descriptions — the plan file has descriptions
- Always include git state — branch, commits, and dirty-tree status
- 10-15 lines max — longer means you're duplicating docs
- Generate immediately — do not ask "Want me to add more detail?"
- No files — generate text output only, never write a handoff file

## Red flags — stop if you're doing any of these

- Writing a `.claude/HANDOFF.md` or any file
- Asking "Should I include X?" or "Want more detail?"
- Listing full task descriptions in the prompt
- Prompt longer than 20 lines
- Skipping git state
