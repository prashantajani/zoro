# Zoro

Personal orchestration agent for Claude Code. Wake with **"zoro, ..."** in any project on any machine.

This repo is **both** a Claude Code plugin marketplace AND the plugin itself — single-repo pattern. Install once, get the agent.

## Install

Inside Claude Code:

```
/plugin marketplace add prashantajani/zoro
/plugin install zoro@zoro
```

Then in any project, say:

```
zoro, lets work on this project
```

If it's a project Zoro hasn't seen before, it'll offer to onboard (creates `docs/zoro/` with a modular doc tree). Say yes. From there: discuss, plan, approve, execute, verify, done.

## What's inside

**Skills:**
- `zoro-orchestrator` — the brain (auto-loads when you say "zoro")
- `zoro-project-onboard` — first-touch project doc setup
- `zoro-inventory` — toolbox map of all skills/agents/commands in `~/.claude/`

**Subagents:**
- `zoro-explorer` — read-only codebase mapper
- `zoro-doc-keeper` — `docs/zoro/` maintainer
- `zoro-verifier` — universal final-gate verifier with four-lens checks

**Commands:**
- `/zoro` — manual fallback to wake the orchestrator

**Hooks:**
- `UserPromptSubmit` — wake-word detection ("zoro" → loads orchestrator)
- `SessionStart` — primes project context and toolbox inventory state

## How it behaves

- **Wake on "zoro".** A UserPromptSubmit hook detects your address and forces the orchestrator skill to load. (Skill auto-invocation alone is unreliable — the hook is the safety net.)
- **Toolbox-aware.** Reads everything in `~/.claude/`. When it wants to improve a non-Zoro skill, it forks with the `-by-zoro` suffix instead of editing in place. You see the new file before it's used. Originals never get touched, so `/plugin update` stays safe.
- **Plan first, verify last.** Every task ends with the verifier (four lenses: plan-conformance, works, no regressions, docs in sync). One auto-fix attempt allowed; second failure surfaces to you. No back-and-forth loops.
- **Per-project docs.** `docs/zoro/` modular tree with INDEX, overview, modules, business rules, ADRs, ledger. Lives with the project, gitignored by default.

## The conversation loop

```
1. Hear        user describes task
2. Orient      reads project docs + toolbox inventory
3. Discuss     asks only the questions that change the plan
4. Plan        concrete plan: steps, subagents, forks, new tools
5. (Approve)   you say go
6. Execute     runs silently
7. Verify      mandatory pass before declaring done
8. Update docs  doc-keeper updates docs/zoro/
9. Report      one summary, one status line
```

## Iterating

This plugin is meant to be hacked on. Edit files locally, push to this repo, run `/plugin update zoro` to pull. Claude Code watches plugin directories and reloads skills/agents on file change without restart, so you can also tweak `~/.claude/plugins/zoro/...` directly during a session for live testing.

## Hard rules (deliberate)

- Never auto-deploy, never auto-merge, never auto-publish.
- Never modify originals of forked skills/agents.
- Never make a second silent fix attempt after the verifier fails twice.
- Never silently attach MCP connectors.

## Phase plan

- **Phase 1 (this version, v0.2):** orchestrator, onboarding, inventory, explorer, doc-keeper, verifier, hooks. Minimum viable Zoro.
- **Phase 2:** `zoro-author` meta-skill (handles forks and new component creation safely), full subagent roster (architect, reviewer, debugger, researcher), `zoro-project-update-docs`.
- **Phase 3:** Cross-tool ports (Codex CLI, Copilot CLI), `bin/zoro` helper, custom statusline.

## License

MIT. See LICENSE.
