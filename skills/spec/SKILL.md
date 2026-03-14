---
description: Create or view a project spec with design and tasks
argument-hint: "[name] or [from-jira TICKET-123]"
---

# Spec

Create structured specs that decompose features into design and implementation tasks. Specs live in `docs/specs/{spec-name}/` within the current repo.

## Invocation Modes

Parse the argument to determine the mode:

1. **No argument** — interactive mode: ask what to build
2. **`from-jira TICKET-123`** — pull Jira issue as input brief (use `get_jira_issue` MCP tool)
3. **`@file.md`** — generate spec from attached document content
4. **Existing spec name** — show status of that spec
5. **New name** — interactive mode, pre-set the spec name

## If Spec Exists: Show Status

Read all files in `docs/specs/{spec-name}/`. Display:

- Spec tier (standard/full)
- Task progress: `[X/Y tasks complete]`
- Current task from `next-step.md` (if present)
- Suggest: "Run `/next-task {spec-name}` to execute the next task"

## If Creating New Spec

### Step 1: Get Feature Description

- **Interactive**: Ask "What do you want to build?" then ask clarifying questions **one at a time** to refine the idea. Keep responses short (~200-300 words). Do not dump a wall of text.
- **From Jira**: Fetch issue details with `get_jira_issue`, use title + description + acceptance criteria as brief
- **From file**: Read the attached file content as the brief

### Step 2: Explore Codebase

Use Glob and Grep to understand:
- Relevant existing code, patterns, and conventions
- Files that will need modification
- Test patterns already in use
- Related features or similar implementations

### Step 3: Auto-Detect Tier

Based on scope, select a tier. The user can override by saying "make this full/standard".

| Tier | When | Files Generated |
|------|------|-----------------|
| **Standard** | 1-3 days | `tasks.md` + `next-step.md` |
| **Full** | 3+ days or cross-cutting | `design.md` + `tasks.md` + `next-step.md` |

### Step 4: Generate Spec Files

Create `docs/specs/{spec-name}/` directory and generate files using the [templates/](templates/):

- **Standard**: Use `templates/tasks.md` for `tasks.md`
- **Full**: Use `templates/design.md` for `design.md`, `templates/tasks.md` for `tasks.md`

For both tiers, also generate `next-step.md`:

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
- Reference actual files and patterns discovered in Step 2
- Tasks should be concrete coding activities producing testable code
- Two-level max task hierarchy (task -> sub-tasks)
- Each task includes inline acceptance criteria describing done
- **Every task AND sub-task MUST have a `- [ ]` checkbox** — this is how `/next-task` tracks progress. Match the template format exactly:
  ```
  - [ ] 1. Top-level task title
    - [ ] 1.1 Sub-task title
      - Implementation detail (no checkbox — these are just notes)
      - _Acceptance: [criteria]_
  ```

**Chunked output — do not generate the entire spec at once:**
- Output ~200-300 words at a time, then **stop and ask the user if it looks right** before continuing
- Always finish the current paragraph — going over 300 words to complete a thought is fine, cutting mid-sentence is not
- This applies to both design.md and tasks.md generation
- Incorporate user feedback into subsequent output — adjust direction based on what they say, don't just append
- The user can ask to increase the chunk size if they want faster output
- The full documents still get written; this is about pacing output for careful user review

### Step 5: Present Summary

After all sections have been reviewed and written, show:
- Tier selected and why
- Total number of tasks generated
- First task title
- Suggest: "Run `/next-task {spec-name}` to start implementation"
