---
name: zoro-inventory
description: Inventory of all skills, subagents, and commands available across the user's ~/.claude/ directory. Use at the start of any Zoro session that involves planning, and whenever Zoro needs to check whether an existing capability covers a task before authoring something new. Reads from ~/.claude/skills/, ~/.claude/agents/, ~/.claude/commands/, and ~/.claude/plugins/*. Returns a compact map: name, type, source (raw vs plugin), purpose (one-line from description).
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Zoro Toolbox Inventory

Build a compact map of what's in `~/.claude/`. Used by the orchestrator to know what's available before planning.

## What to scan

For each location below, list every entry. Skip anything that's not a recognizable skill/agent/command file.

1. **User raw skills:** `~/.claude/skills/*/SKILL.md`
2. **User raw agents:** `~/.claude/agents/*.md`
3. **User raw commands:** `~/.claude/commands/*.md`
4. **Plugin-provided skills:** `~/.claude/plugins/*/skills/*/SKILL.md`
5. **Plugin-provided agents:** `~/.claude/plugins/*/agents/*.md`
6. **Plugin-provided commands:** `~/.claude/plugins/*/commands/*.md`

On Windows, `~/.claude/` resolves to `%USERPROFILE%\.claude\`.

## How to extract

For each file:

1. Read just the YAML frontmatter (the block between the first two `---` lines).
2. Extract `name` and `description` (truncate description to ~100 chars if longer).
3. Note the source: `raw` (in `~/.claude/skills|agents|commands/`) or `plugin:<plugin-name>` (in `~/.claude/plugins/<plugin>/...`).

Don't read the body of every file — that would be slow and pointless. Frontmatter is enough for inventory.

## Output format

Return a single markdown block, organized by type, source-tagged, alphabetized:

```
## Zoro Toolbox Inventory
*Generated: <YYYY-MM-DD HH:MM>*

### Skills (N total)

**From plugin:zoro:**
- `zoro-orchestrator` — <description>
- `zoro-project-onboard` — <description>
- ...

**From plugin:skill-creator:**
- `skill-creator` — <description>

**Raw (~/.claude/skills/):**
- `coder` — <description>
- `pr-review` — <description>
- ...

### Subagents (N total)

**From plugin:zoro:**
- `zoro-explorer` — <description>
- `zoro-verifier` — <description>
- ...

**Raw (~/.claude/agents/):**
- ...

### Commands (N total)
- ...

### `-by-zoro` forks
- `coder-by-zoro` (forked from `coder`, raw) — <reason if known>
- ...
```

## When called from SessionStart hook

Write the output to `~/.claude/zoro-inventory-cache.md` and return a one-line summary: "Toolbox inventory: N skills, M subagents, K commands. See ~/.claude/zoro-inventory-cache.md for details."

The orchestrator reads the cache file when planning, so it doesn't have to wait for inventory mid-conversation.

## When called on demand

Return the full inventory inline. The user might be debugging "what does Zoro know about?" — give them the answer directly. Also write the cache file so subsequent sessions skip the rescan.

## Notes

- This skill is read-only. Never modify anything in `~/.claude/`.
- If a file's frontmatter is malformed, list it as `<filename> — [malformed frontmatter]` and continue. Don't fail the whole inventory over one bad file.
- Cache invalidation: regenerate fresh whenever called. The SessionStart hook calls this once per session.
