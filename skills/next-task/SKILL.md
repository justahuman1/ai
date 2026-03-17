---
description: Execute the next pending task from a spec. Auto-commits on completion.
argument-hint: "[spec-name]"
---

# Next Task

Execute the next pending task from a spec, verify it, update tracking state, and commit.

## Process

### Step 1: Find the Spec

- If spec-name provided, use it directly
- If no spec-name provided, infer:
  1. If the current conversation already references a spec name, use it
  2. Look for `docs/specs/*/progress.md` files with a Current Task (not all tasks complete)
  3. If exactly one active spec found, use it
  4. If multiple active specs, list them and ask which one
  5. If none found, report "No active specs in docs/specs/" and stop
- Read all files in `docs/specs/{spec-name}/`

### Step 2: Determine Current Task

In order of precedence:

1. **`progress.md` exists** — read the Current Task field
2. **`progress.md` missing but `tasks.md` exists** — first unchecked task; create `progress.md`
3. **All tasks complete** — report "All tasks complete for {spec-name}", stop

### Step 3: Read Context

- Read files listed in the current task's sub-steps to understand existing code
- Read `design.md` (if it exists) for architectural guidance
- Read `progress.md` for session context and the **Lessons** section for accumulated insights from all prior tasks
- Acceptance criteria are inline in the task — no separate file to consult

### Step 4: Plan

- Enter plan mode
- Propose approach: files to touch, test strategy, implementation plan
- User reviews and may add context (e.g., "last task revealed X")
- Write plan file, exit plan mode
- Include `**Spec:** {spec-name}` at the top of the plan so the spec name survives context clearing

### Step 5: TDD Execution

- Write a failing test that encodes the task's acceptance criteria
- Implement code to make the test pass
- Run all relevant tests — fix until green
- If TDD doesn't apply (e.g., config changes, template edits, deletions), skip the test step and verify manually

### Step 6: Update State

- **`tasks.md`**: check off the completed task `- [x]`
- **`progress.md`**: move completed task to Done list, set next Current Task, and update two sections:
  - **Context** (ephemeral — overwritten each task): what the *next* task needs to know
  - **Lessons** (accumulative — append only, never remove): things that took multiple attempts or user correction to get right. Tagged by task number, can be verbose with code references. Skip obvious stuff — only record what you'd get wrong again without the note. **Present proposed lessons to the user for confirmation before writing.**

Example `progress.md` update:
```markdown
# Progress

## Current Task
Task 3: Add input validation

## Status
Not started

## Context
- Task 4 (API endpoints) will need to call validation before persistence

## Lessons
- [Task 2] Initially added validation inline in the model — user wanted it as a separate middleware layer. Validation is its own concern in this codebase, not co-located with models (`src/middleware/validate.ts`).
- [Task 2] Schema migrations must be regenerated after any model change — forgot this and tests failed until user pointed it out. Run `npm run migrate:gen` after touching `schema.ts`.

## Done
- Task 1: Set up project structure
- Task 2: Implement core data model
```

### Step 7: Commit

Commit all changes (code + spec state files) with message:
```
spec/{spec-name}: task N - {task title}
```

### Step 8: Report

Output:
```
Completed: Task N — {title}
Next up: Task M — {title}
Progress: X/Y tasks
```

Then stop. Do not auto-start the next task.

## Rules

- Always verify (run tests) before marking a task done
- **Never commit without updating `progress.md` and `tasks.md` first.** The commit must include both code changes and state file updates. If you're about to commit and haven't updated the state files, stop and do it now.
- If blocked, update `progress.md` status to `Blocked: {reason}` and stop
- Don't modify `design.md` content — it's a reference, not a living document
- One commit per task
- Don't skip tasks — execute them in order
- If running in plan mode, include "Do not start the next task without user asking" in the plan output. The plan survives context clearing; behavioral rules do not.
