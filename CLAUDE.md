# CLAUDE.md

Guidance for Claude Code (and other AI assistants) working in this repository.

## Overview

A single-purpose shell utility: `install.sh` installs the official
[massCode](https://github.com/massCodeIO/massCode) desktop AppImage on
Debian/Ubuntu Linux. There is no application server or deployment target —
the deliverable is a script the user runs on their own machine.

## Project layout

- `install.sh` — the installer (idempotent: safe to re-run). Bump `VERSION`
  and `SHA256` near the top to track a new massCode release.
- `README.md` — usage, the list of unrelated lookalike packages to avoid,
  cleanup of conflicting installs, and troubleshooting.
- `CLAUDE.md` — this file.

## Common commands

- Run the installer: `bash install.sh`
- Syntax/lint the script: `bash -n install.sh` (or `shellcheck install.sh`)

There is no build, dependency install, or automated test suite.

## Conventions

- Keep `install.sh` as bash with `set -euo pipefail`, idempotent, and never
  hardcode a username — derive paths from `$HOME`.
- When changing the pinned massCode version, update `VERSION` **and** the
  matching `SHA256` together, and reflect the version in `README.md`.

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
