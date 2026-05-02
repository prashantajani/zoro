#!/usr/bin/env bash
# SessionStart hook - silently primes Zoro with project context AND notes
# the toolbox inventory cache state.
# Cross-platform: works on macOS, Linux, and Windows under Git Bash.
set -euo pipefail

cwd=$(pwd)
project_indicator="not a repo"
zoro_status="no docs/zoro/"
inventory_status="not yet built"

# Detect git repo
if [[ -d "$cwd/.git" ]]; then
  project_indicator="git repo"
fi

# Detect docs/zoro/
if [[ -f "$cwd/docs/zoro/INDEX.md" ]]; then
  zoro_status="docs/zoro/ exists"
fi

# Detect inventory cache (cross-platform HOME resolution)
home_dir="${HOME:-${USERPROFILE:-}}"
if [[ -n "$home_dir" ]] && [[ -f "$home_dir/.claude/zoro-inventory-cache.md" ]]; then
  inventory_status="cache exists"
fi

# Emit context. We always emit something so Zoro knows the state.
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Zoro session priming: cwd is $project_indicator. Project status: $zoro_status. Toolbox inventory: $inventory_status. When the user invokes Zoro (says 'zoro' or runs /zoro), the orchestrator should: (1) read ~/.claude/zoro-inventory-cache.md if it exists, or invoke the zoro-inventory skill if not; (2) read docs/zoro/INDEX.md if the project has it; (3) follow the orchestrator's conversation loop including the mandatory verify step before reporting done."
  }
}
EOF

exit 0
