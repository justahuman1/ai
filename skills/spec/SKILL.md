---
description: Create or view a project spec with requirements, design, and tasks
argument-hint: "[name] or [from-jira TICKET-123]"
---

# Spec

Create structured specs that decompose features into requirements, design, and implementation tasks. Specs live in `docs/specs/{spec-name}/` within the current repo.

## Invocation Modes

Parse the argument to determine the mode:

1. **No argument** — interactive mode: ask what to build
2. **`from-jira TICKET-123`** — pull Jira issue as input brief (use `get_jira_issue` MCP tool)
3. **`@file.md`** — generate spec from attached document content
4. **Existing spec name** — show status of that spec
5. **New name** — interactive mode, pre-set the spec name

## If Spec Exists: Show Status

Read all files in `docs/specs/{spec-name}/`. Display:

- Spec tier (micro/quick/full)
- Requirements count with completion: `[3/7 requirements satisfied]`
- Current task from `next-step.md` (if present)
- Suggest: "Run `/next-task {spec-name}` to execute the next task"

## If Creating New Spec

### Step 1: Get Feature Description

- **Interactive**: Ask "What do you want to build?" — gather enough detail for scope assessment
- **From Jira**: Fetch issue details with `get_jira_issue`, use title + description + acceptance criteria as brief
- **From file**: Read the attached file content as the brief

### Step 2: Explore Codebase

Use Glob and Grep to understand:
- Relevant existing code, patterns, and conventions
- Files that will need modification
- Test patterns already in use
- Related features or similar implementations

### Step 3: Auto-Detect Tier

Based on scope, select a tier. The user can override by saying "make this full/quick/micro".

| Tier | When | Files Generated |
|------|------|-----------------|
| **Micro** | <1 day, 1-3 files | `spec.md` only |
| **Quick** | 1-3 days | `requirements.md` + `tasks.md` + `next-step.md` |
| **Full** | 3+ days or cross-cutting | `requirements.md` + `design.md` + `tasks.md` + `next-step.md` |

### Step 4: Generate Spec Files

Create `docs/specs/{spec-name}/` directory and generate files using the templates in `~/.claude/skills/spec/templates/`:

- **Micro**: Use `templates/micro.md` structure for a single `spec.md`
- **Quick**: Use `templates/requirements.md` for `requirements.md`, `templates/tasks.md` for `tasks.md`
- **Full**: Use all three — `templates/requirements.md`, `templates/design.md`, `templates/tasks.md`

For Quick and Full tiers, also generate `next-step.md`:

```markdown
# Next Step

## Current Task
Task 1: {first task title from tasks.md}

## Status
Not started

## Done
(none yet)
```

**Generation rules:**
- Fill in the templates with real content based on the feature brief and codebase exploration
- Use EARS format (WHEN/IF/WHILE/WHERE + SHALL) for all acceptance criteria
- Reference actual files and patterns discovered in Step 2
- Tasks should be concrete coding activities producing testable code
- Two-level max task hierarchy (task -> sub-tasks)
- Each task should reference which requirements it satisfies
- **Every task AND sub-task MUST have a `- [ ]` checkbox** — this is how `/next-task` tracks progress. Match the template format exactly:
  ```
  - [ ] 1. Top-level task title
    - [ ] 1.1 Sub-task title
      - Implementation detail (no checkbox — these are just notes)
      - _Requirements: [REQ-1]_
  ```

### Step 5: Present Summary

Show:
- Tier selected and why
- Number of requirements generated
- Number of tasks generated
- First task title
- Suggest: "Run `/next-task {spec-name}` to start implementation"
