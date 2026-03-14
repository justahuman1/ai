# Tasks: Bubble — Isolated Task Execution

## Goal

Create a `/bubble` skill that runs Claude Code tasks in isolated devcontainers. Enables unattended, secure execution of spec tasks on any codebase.

**Acceptance Criteria:**
- `/bubble setup` scaffolds `.devcontainer/` in the current project
- `/bubble my-spec` launches a container and runs `/next-task` inside it
- `/bubble my-spec task 3` runs a specific task
- Works with any language/toolchain
- Container has firewall restricting network to necessary services

**Open risks:**
- `devcontainer` CLI may not work reliably from within a Claude Code session — task 1 validates this
- This is a skill that orchestrates external Claude processes, which is untested territory

## Tasks

- [ ] 1. Validate devcontainer CLI feasibility
  - Check if `devcontainer up` and `devcontainer exec` work from a Claude Code bash session
  - Test: can Claude launch a container, run `claude --version` inside it, and get output back?
  - Document findings — if this fails, the rest of the spec needs a different approach
  - _Acceptance: documented proof that devcontainer CLI works (or doesn't) from Claude Code_

- [ ] 2. Create `/bubble` skill with SKILL.md
  - `skills/bubble/SKILL.md` with setup and run modes
  - Setup mode: check for `.devcontainer/`, scaffold from templates if missing
  - Run mode: launch container, mount workspace + `~/.claude/`, execute `claude -p` inside it
  - _Depends on: task 1 (must succeed)_
  - _Acceptance: skill loads in Claude Code_

- [ ] 3. Add devcontainer template files
  - `skills/bubble/templates/` with `devcontainer.json`, `Dockerfile`, `init-firewall.sh`
  - Based on Anthropic reference implementation
  - Language-agnostic — Node.js only for Claude Code runtime
  - Firewall: allow Claude API, npm, GitHub; deny everything else
  - _Depends on: task 1_
  - _Acceptance: templates exist and are referenced by SKILL.md_

- [ ] 4. Define run workflow in SKILL.md
  - `/bubble {spec-name}` — runs `/next-task {spec-name}` in container with `--dangerously-skip-permissions`
  - `/bubble {spec-name} task N` — runs a specific task
  - Mount project workspace as working directory
  - Mount `~/.claude/` for API keys and skills
  - Stream or report output back to the user
  - _Depends on: task 2, task 3_
  - _Acceptance: SKILL.md documents full run workflow with examples_

- [ ] 5. Document in README
  - Add `/bubble` to skills section with the cohesive story: `/spec` plans it, `/next-task` runs it, `/bubble` isolates it
  - Note experimental status
  - _Depends on: task 4_
  - _Acceptance: README lists the skill_
