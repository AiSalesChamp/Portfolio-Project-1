# CLAUDE.md

Guidance for Claude Code (and other AI assistants) working in this repository.

## Repository status

**This repository is currently empty.** There are no source files, no commits on
`main`, and no build/test tooling yet. The only concrete fact about the project
so far is its name (`Portfolio-Project-1`) and owner (`AiSalesChamp`).

When you start work here, the first thing to do is determine — by asking the
user or by reading whatever files have just been added — what the project
actually is. Do **not** infer a stack, framework, or architecture from the
repository name alone. Update this file as soon as the real shape of the
project is known.

## What to fill in once code exists

Replace the sections below with concrete, verified information. Delete any
section that does not apply rather than leaving placeholder text.

### Overview
- One or two sentences describing what the project does and who it is for.
- Production URL / deployment target, if any.

### Tech stack
- Language(s) and runtime versions (record exact versions from `.nvmrc`,
  `package.json` `engines`, `pyproject.toml`, `go.mod`, etc.).
- Framework(s) and major libraries.
- Database / external services.
- Package manager (npm / pnpm / yarn / uv / poetry / cargo / …).

### Project layout
- Top-level directories and what lives in each.
- Where entry points are (e.g. `src/main.ts`, `app/page.tsx`, `cmd/server`).
- Where tests live and the naming convention used.

### Common commands
Document the exact commands the user runs locally. Examples to verify and
record:
- Install dependencies
- Run the dev server
- Run tests (and how to run a single test)
- Run the linter / formatter / type checker
- Build for production

### Conventions
- Code style rules that aren't enforced by tooling.
- Naming patterns (files, components, exports).
- Commit message style, if any (Conventional Commits, etc.).
- Anything that has bitten contributors before and is worth flagging.

## Workflow for AI assistants

1. **Branch.** Active development happens on
   `claude/add-claude-documentation-cpsYv` for the documentation task that
   created this file. For new tasks, follow whatever branch instructions the
   user provides; do not push to `main` without explicit permission.
2. **Pull requests.** After pushing, open a draft PR against the default
   branch via the GitHub MCP tools.
3. **Ask before guessing.** Because this repo has no code yet, almost any
   non-trivial assumption about structure, stack, or conventions is a guess.
   Prefer asking the user one clarifying question over inventing details.
4. **Keep this file honest.** If you add code, update the relevant section
   above in the same change. If a section is still unknown, leave it marked
   as such rather than filling it with plausible-sounding fiction.

## Notes for the human maintainer

- This file was generated when the repo was empty, so it is mostly a
  scaffold. Trim or rewrite it freely once the project takes shape — its
  value comes from being accurate, not from being long.
