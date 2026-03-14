# Design: Rework Spec Skill

## Overview

The `/spec` and `/next-task` skills implement a spec-based development workflow forked from Kiro. Three things are wrong: requirements.md is a business-analyst artifact that engineers don't read, the templates are hardcoded for web apps, and micro tier solves a problem that doesn't exist (if it's that small, just use Claude). This rework strips all three, adds TDD execution, and produces a workflow light enough to understand fully by reading two SKILL.md files and three templates.

## Key Design Decisions

| Decision                                         | Rationale                                                                                                                                                                                                                                                                                                | Rejected Alternative                                                                                                                             |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Drop requirements.md entirely                    | It's a separate file with user stories, stakeholders, glossary, and EARS syntax that no engineer reads during implementation. Acceptance criteria belong inline in tasks.md, next to the work they verify.                                                                                               | "Lite" requirements — still a separate file to maintain and cross-reference.                                                                     |
| Drop micro tier                                  | A spec for a 2-hour fix costs more than the fix. Standard tier without requirements is already 2 files (tasks.md + next-step.md) — that's light enough. Below that threshold, just talk to Claude.                                                                                                       | Keep micro as single-file option — the new standard tier is already as light as micro was.                                                       |
| TDD at execution time, not spec time             | Writing tests before exploring the codebase locks you into interfaces you haven't validated. Thin-slice TDD in `/next-task` (test → implement → verify per task) gives tight feedback loops with real code context.                                                                                      | Write all tests upfront after design — same drift problem as requirements.md. A big upfront artifact that breaks on contact with implementation. |
| Templates are structural skeletons, not examples | Current design.md has REST endpoints, JWT auth, TypeScript interfaces, CDN config. Current tasks.md has a 6-phase web-app pipeline. These are useless for database or infra work. Templates should provide section headers and 1-line guidance — Claude fills in real content from codebase exploration. | Domain-specific template variants — doesn't scale, and the whole point is one workflow for any codebase.                                         |
| Relative template paths                          | Skills ship as plugin directories. `~/.claude/skills/spec/templates/` breaks for any other user. Relative `[templates/](templates/)` links work everywhere.                                                                                                                                              | N/A — this is a bug fix, not a design choice.                                                                                                    |

## Tiers

Two tiers. Auto-detected by scope, user can override.

| Tier | When | Generated Files | `/next-task` integration |
|------|------|-----------------|--------------------------|
| **Standard** | 1-3 days, contained scope | `tasks.md` + `next-step.md` | Yes |
| **Full** | 3+ days or cross-cutting | `design.md` + `tasks.md` + `next-step.md` | Yes |

**Standard** is the default. Most work fits here — a feature, a bug fix that touches multiple files, a refactor. `tasks.md` opens with a Goal section (what + why + acceptance criteria), then ordered tasks with checkboxes and per-task acceptance.

**Full** adds `design.md` when there are architectural decisions worth recording — new subsystems, cross-component changes, work where "why this approach" matters as much as "what to do." Design.md captures decisions and alternatives so future readers understand the tradeoffs, not just the outcome.

No tier below standard. If you can describe the work in a sentence and finish it in a few hours, skip the spec entirely.

## `/next-task` TDD Execution

Each task executes as a thin slice: test → implement → verify → commit.

```
1. Read task + acceptance criteria from tasks.md
2. Read design.md (if full tier) for architectural context
3. Write a failing test that encodes the acceptance criteria
4. Implement the code to make the test pass
5. Run all tests — fix until green
6. Update tasks.md (check off task) + next-step.md (advance pointer)
7. Commit: code + test + spec state in one atomic commit
8. Stop. Do not auto-start next task.
```

Why thin-slice over waterfall (all tests then all code):
- You learn if the design holds after task 1, not after writing 20 tests against an interface you imagined
- One task at a time matches `/next-task`'s existing model — no workflow change, just reordering within a task
- A batch of upfront tests has the same drift problem as requirements.md — a big artifact that breaks on contact with reality

Why test before code, not alongside:
- The test is a contract. Writing it first forces you to think about the interface before the implementation.
- When the test passes, you're done. No ambiguity about whether acceptance criteria are met.
- Refactoring is safe from the start — the test survives any code restructuring.

## Plan Mode per Task

Each `/next-task` invocation starts in **plan mode**. The agent reads the spec, the previous task's outcome, and the current task — then proposes an execution plan. The user reviews, discusses, and adds their own context before approving.

```
/next-task → plan mode
  ├── Agent reads: tasks.md, next-step.md, design.md (if exists)
  ├── Agent proposes: approach, files to touch, test strategy
  ├── User adds context: "last task revealed X", "this module works like Y"
  └── Plan file written → exit plan mode

→ fresh context, plan file loaded
  ├── Write failing test
  ├── Implement
  ├── Verify
  └── Commit
```

Why this works:
- **The user is the continuity between tasks.** The spec tracks state, but the user carries understanding of how the last task went and what to adjust. Plan mode makes space for that knowledge transfer.
- **Execution context stays clean.** Planning discussion doesn't eat the implementation context window. The plan file persists across context clearing.
- **No extra tooling.** Plan mode already exists in Claude Code — we're just making it the default entry point for `/next-task`.

## Future Work

- **Chunked output with user review cycles.** Instead of generating entire spec files in one shot, `/spec` should output each section (~200-300 words) and pause for user feedback before continuing. The full design.md and tasks.md still get written, but the user reviews and course-corrects incrementally rather than receiving a wall of text. This applies to both design.md sections and task batches. Reference: [How I'm Using Coding Agents (Sept 2025)](https://blog.fsck.com/2025/10/05/how-im-using-coding-agents-in-september-2025/)
