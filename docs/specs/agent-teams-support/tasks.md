# Tasks: Agent Teams Support

## Goal

Teach `/spec` to generate dependency-aware tasks so that Claude Code agent team leads can read a spec and assign parallelizable work to teammates.

**Acceptance Criteria:**
- Tasks in generated specs include `_Depends on: ..._` annotations where dependencies exist
- Tasks with no dependencies are implicitly parallel-ready
- README documents agent teams as an experimental workflow

## Tasks

- [ ] 1. Add dependency annotation to task template
  - Add `_Depends on: task N_` as an optional field in `skills/spec/templates/tasks.md`
  - Keep it optional — tasks with no dependencies omit the line
  - _Acceptance: template shows dependency syntax in the example_

- [ ] 2. Update `/spec` generation rules to emit dependencies
  - In `skills/spec/SKILL.md` Step 4, instruct the generator to identify task dependencies
  - When a task requires output from a prior task, annotate with `_Depends on: task N[, task M]_`
  - Tasks that only depend on existing codebase state omit the annotation
  - _Acceptance: generation rules in SKILL.md mention dependency annotation_

- [ ] 3. Add agent teams section to README
  - Describe the experimental workflow: `/spec` generates the plan, team lead assigns from it
  - Note that teams, `/next-task`, and solo work all compose — use whatever fits
  - _Acceptance: README has an agent teams section_
