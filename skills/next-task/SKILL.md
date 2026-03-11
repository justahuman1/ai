---
description: Execute the next pending task from a spec. Auto-commits on completion.
argument-hint: "<spec-name>"
---

# Next Task

Execute the next pending task from a spec, verify it, update tracking state, and commit.

## Process

### Step 1: Find the Spec

- If no spec-name provided, list available specs in `docs/specs/` and ask which one
- Read all files in `docs/specs/{spec-name}/`

### Step 2: Determine Current Task

In order of precedence:

1. **`next-step.md` exists** — read the Current Task field
2. **`next-step.md` missing but `tasks.md` exists** — first unchecked task; create `next-step.md`
3. **Only `spec.md` (micro tier)** — first unchecked item in the How section
4. **All tasks complete** — report "All tasks complete for {spec-name}", stop

### Step 3: Read Context

- Read files listed in the current task's sub-steps to understand existing code
- Read `requirements.md` to understand acceptance criteria being targeted
- Read `design.md` (if it exists) for architectural guidance

### Step 4: Implement the Task

- Make the code changes described in the task
- Follow patterns and conventions discovered in existing code
- Write tests as specified in the task sub-steps

### Step 5: Verify

- Run relevant tests (find and use the project's test runner)
- Check that acceptance criteria from the referenced requirements are met
- If tests fail, fix and re-run before proceeding

### Step 6: Update State

- **`tasks.md`** (or `spec.md` for micro): check off the completed task `- [x]`
- **`requirements.md`** (if present): check off any requirements whose acceptance criteria are now fully satisfied
- **`next-step.md`**: move completed task to Done list, set next Current Task

Example `next-step.md` update:
```markdown
# Next Step

## Current Task
Task 3: Add input validation

## Status
Not started

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
- Don't modify requirements or design content — only check off their checkboxes
- One commit per task
- Don't skip tasks — execute them in order
- If running in plan mode, include "Do not start the next task without user asking" in the plan output. The plan survives context clearing; behavioral rules do not.
