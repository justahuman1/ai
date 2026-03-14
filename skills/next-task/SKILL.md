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
  2. Look for `docs/specs/*/next-step.md` files with a Current Task (not all tasks complete)
  3. If exactly one active spec found, use it
  4. If multiple active specs, list them and ask which one
  5. If none found, report "No active specs in docs/specs/" and stop
- Read all files in `docs/specs/{spec-name}/`

### Step 2: Determine Current Task

In order of precedence:

1. **`next-step.md` exists** — read the Current Task field
2. **`next-step.md` missing but `tasks.md` exists** — first unchecked task; create `next-step.md`
3. **All tasks complete** — report "All tasks complete for {spec-name}", stop

### Step 3: Read Context

- Read files listed in the current task's sub-steps to understand existing code
- Read `design.md` (if it exists) for architectural guidance
- Read `next-step.md` for session context from previous tasks (learnings, decisions)
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
- **`next-step.md`**: move completed task to Done list, set next Current Task, and add a **Context** section capturing:
  - What was learned or changed during this task
  - Decisions made that affect upcoming work
  - Any adjustments to the remaining plan

Example `next-step.md` update:
```markdown
# Next Step

## Current Task
Task 3: Add input validation

## Status
Not started

## Context
- Task 2 revealed the data model needs a `validated` flag — added to schema
- Decided to use zod for validation since the project already depends on it
- Task 4 (API endpoints) will need to call validation before persistence

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
- If blocked, update `next-step.md` status to `Blocked: {reason}` and stop
- Don't modify `design.md` content — it's a reference, not a living document
- One commit per task
- Don't skip tasks — execute them in order
- If running in plan mode, include "Do not start the next task without user asking" in the plan output. The plan survives context clearing; behavioral rules do not.
