# ai dotfiles

AI skills and config for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). **Lightweight** spec-based development workflow — minimal abstraction, plain markdown you can read and edit, structured specs, TDD execution, one task at a time.

## Setup

```bash
git clone https://github.com/justahuman1/ai.git ~/.config/ai
chmod +x ~/.config/ai/setup.sh
~/.config/ai/setup.sh
```

`setup.sh` symlinks each skill directory into `~/.claude/skills/`. Safe to re-run.

## How It Works: Stow-Style Composition

`~/.claude/` is the composed target — Claude Code reads skills from here. Multiple source directories contribute via per-item symlinks:

```
~/.claude/skills/
├── spec       -> ~/.config/ai/skills/spec          (public, from this repo)
├── next-task  -> ~/.config/ai/skills/next-task      (public, from this repo)
├── my-skill   -> ~/.config/ai-private/skills/my-skill  (your private layer)
└── ...
```

This lets you:
- Share public skills via git while keeping private/work-specific skills separate
- Add your own private layer in `~/.config/ai-private/` (or anywhere) with its own symlinks
- Avoid all-or-nothing symlinks that force everything into one repo

## Skills

### `/spec` — Create structured specs

Decomposes a feature into a design doc and implementation tasks. Specs live in `docs/specs/{name}/` within your project repo.

| Tier | When | Files |
|------|------|-------|
| Standard | 1-3 days | `tasks.md` + `next-step.md` |
| Full | 3+ days or cross-cutting | `design.md` + `tasks.md` + `next-step.md` |

Features:
- Auto-detects tier based on scope (overridable)
- Can pull from Jira issues (`/spec from-jira TICKET-123`)
- Chunked output — reviews ~200-300 words at a time for feedback
- Tasks include inline acceptance criteria

### `/next-task` — Execute tasks with TDD

Picks up the next pending task from a spec and executes it:

1. Read task + acceptance criteria
2. Write a failing test (when applicable)
3. Implement code to pass
4. Verify all tests green
5. Update spec state (`tasks.md` checkboxes, `next-step.md` context)
6. Commit with `spec/{name}: task N - {title}`

Auto-infers which spec to use if only one is active. Captures context between tasks so you (or Claude) can pick up where you left off.

## Experimental: Agent Teams + Bubble

We're experimenting with [Claude Code agent teams](https://code.claude.com/docs/en/agent-teams) and isolated execution via [devcontainers](https://code.claude.com/docs/en/devcontainer). The vision:

> `/spec` plans it. `/next-task` runs it. `/bubble` isolates it. Teams parallelize it.

- **Agent teams**: `/spec` generates dependency-annotated tasks so a team lead can assign parallel work to teammates
- **`/bubble`**: runs spec tasks in isolated devcontainers with `--dangerously-skip-permissions` for unattended execution

Both are in-progress — see `docs/specs/agent-teams-support/` and `docs/specs/bubble/` for the specs. We're dogfooding these specs to build the features themselves.

## Adding a Private Layer

Create a separate directory for skills you don't want public:

```bash
mkdir -p ~/.config/ai-private/skills/my-skill
# add SKILL.md, etc.
ln -s ~/.config/ai-private/skills/my-skill ~/.claude/skills/my-skill
```

You can version `~/.config/ai-private/` in a separate (private) repo.

## Prior Art

Forked from [Kiro](https://github.com/jasonkneen/kiro). Tried [GSD](https://github.com/gsd-build/get-shit-done/) but it was too heavyweight — 20+ agent types, complex orchestration, opaque state files. This workflow has 2 skills, plain markdown files you can edit by hand, and a state tracker (`next-step.md`) that's a few lines of text.
