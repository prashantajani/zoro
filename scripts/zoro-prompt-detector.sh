#!/usr/bin/env bash
# UserPromptSubmit hook - detects "zoro" in the user's prompt and forces
# orchestrator skill loading. Outputs JSON with additionalContext when matched.
# Cross-platform: works on macOS, Linux, and Windows under Git Bash.
set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Extract prompt text. Try jq first, fall back to grep/sed.
if command -v jq >/dev/null 2>&1; then
  prompt=$(echo "$input" | jq -r '.prompt // empty')
else
  # Fallback: extract the prompt field via regex. Handles single-line prompts.
  prompt=$(echo "$input" | grep -oE '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"prompt"[[:space:]]*:[[:space:]]*"//; s/"$//')
fi

# Match "zoro" as a whole word, case-insensitive.
if echo "$prompt" | grep -qiE '(^|[^a-zA-Z])zoro([^a-zA-Z]|$)'; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "The user has addressed Zoro by name. Load the zoro-orchestrator skill now and operate as Zoro for the rest of this turn. Follow the orchestrator skill's conversation loop strictly: hear -> orient (read project docs/zoro/INDEX.md AND ~/.claude/zoro-inventory-cache.md) -> discuss -> plan -> (approve) -> execute -> verify -> update docs -> report. The verify step is mandatory before declaring done."
  }
}
EOF
fi

exit 0
