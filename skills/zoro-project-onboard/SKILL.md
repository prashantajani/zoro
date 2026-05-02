---
name: zoro-project-onboard
description: First-touch project onboarding for Zoro. Run when entering a project that has no docs/zoro/ folder. Detects the project's tech stack, modules, and structure, then writes the initial docs/zoro/ tree (INDEX.md, overview.md, tech-stack.md, code-map.md, conventions.md, ledger.md) plus a thin CLAUDE.md pointer at project root. Invoke this whenever Zoro is starting work in a project for the first time.
user-invocable: true
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Task
---

# Zoro Project Onboarding

You are onboarding a project to Zoro. The goal is a small, accurate, modular `docs/zoro/` tree that future Zoro sessions can read to load full context fast.

## Phase 1 - Quick scan (do not read every file)

Run these in parallel via Bash and Glob. Capture the output.

1. `git rev-parse --show-toplevel` — confirm we're in a repo.
2. List package manifests: `package.json`, `composer.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `pom.xml`, `pubspec.yaml`.
3. List build/config files: `Dockerfile`, `docker-compose.yml`, `vite.config.*`, `next.config.*`, `webpack.config.*`, `wp-config.php`, `.env.example`, `tsconfig.json`.
4. Identify framework fingerprints (WordPress: `wp-config.php`, `wp-content/`; Laravel: `artisan`; React: `package.json` deps; Next: `next.config`; etc).
5. `git log --oneline -20` to see recent activity.
6. `find . -maxdepth 3 -type d` to map the top-level shape (skip `node_modules`, `vendor`, `.git`).

## Phase 2 - Confirm with user

Before writing files, present what you found in 4-6 lines and ask:

- Did you get the stack right?
- Are there modules / domains the user wants you to know about that aren't obvious from the tree?
- Anything Zoro should NOT touch (legacy folders, generated code, vendor)?
- Should `docs/zoro/` be gitignored (default: yes) or committed (for team visibility)?

This is a single confirmation, not a Q&A loop. Take their input and proceed.

## Phase 3 - Write the docs tree

Create the following structure at `<project-root>/docs/zoro/`:

```
docs/zoro/
├── INDEX.md
├── overview.md
├── tech-stack.md
├── code-map.md
├── conventions.md
├── ledger.md
├── architecture/
│   └── .gitkeep
├── modules/
│   └── .gitkeep
├── business-rules/
│   └── .gitkeep
├── workflows/
│   └── .gitkeep
└── decisions/
    └── .gitkeep
```

Then add a thin `CLAUDE.md` at project root if none exists, or a Zoro section to it if one does.

If the user said gitignore, append `docs/zoro/` to `.gitignore` (or create one).

### File templates

**INDEX.md** — the entry point. Keep this updated as the doc tree grows.

```markdown
# Zoro Docs - <Project Name>

This is Zoro's living understanding of this project. Read top to bottom for full context, or jump to the relevant section.

## Quick facts
- **Type:** <e.g. WordPress site, Node API, React SPA>
- **Stack:** <one line>
- **Repo:** <git remote>
- **Last Zoro session:** <date - auto-updated by doc-keeper>

## Map of these docs

- `overview.md` — what this project is and why it exists
- `tech-stack.md` — languages, frameworks, build, deploy
- `code-map.md` — directory layout and key files
- `conventions.md` — coding standards observed in this repo
- `architecture/` — system-level diagrams and flows
- `modules/` — per-module deep dives (one file per module)
- `business-rules/` — domain logic by area
- `workflows/` — dev setup, deploy, debugging recipes
- `decisions/` — ADRs (decisions Zoro and the user made)
- `ledger.md` — chronological log of Zoro sessions on this project
```

**overview.md** — 5-15 lines. What it is, who uses it, what matters about it. Do not pad.

**tech-stack.md** — bulleted list: language(s), framework(s), package manager, build, test, lint, deploy target, hosting. One line each.

**code-map.md** — directory tree (top 2 levels) with one-line annotations on each entry. List the 5-10 most important files explicitly.

**conventions.md** — observed conventions: naming, file organization, error handling, commit message style. Mark as `[observed]` vs `[user-stated]`. Empty bullets are fine to fill in later.

**ledger.md** — start with one entry:

```markdown
# Ledger

## <YYYY-MM-DD> — Project onboarded
Initial docs/zoro/ created. Stack detected: <stack>. Modules identified: <list>.
```

**Project-root CLAUDE.md** (thin pointer):

```markdown
# Project context for Claude / Zoro

Full project context lives at `docs/zoro/INDEX.md`. Read that first.

This project uses Zoro for AI-assisted work. To start a session: `zoro, <task>`.
```

## Phase 4 - Hand off

Tell the user, in one paragraph, what you wrote and what comes next. Then return control. The user's actual task can now proceed against fresh context.

## Notes

- **Do not deep-scan modules during onboarding.** Module pages get filled in lazily, the first time Zoro works on that module. Onboarding is a skeleton, not a complete map.
- **If `docs/zoro/` already exists** but is incomplete, do NOT overwrite — fill gaps and tell the user what was added.
- **If a CLAUDE.md already exists** at project root, append a Zoro section rather than overwriting.
