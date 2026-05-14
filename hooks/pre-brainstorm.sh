#!/usr/bin/env bash
set -euo pipefail

# Read tool input from stdin. Exit silently if not brainstorming.
INPUT=$(cat)
SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null || true)

if [[ -z "$SKILL_NAME" ]] || [[ "$SKILL_NAME" != *brainstorming* ]]; then
  exit 0
fi

# Resolve project working directory — hooks may run from plugin root, not project root.
# Claude Code sets CLAUDE_PROJECT_DIR; fall back to PWD.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# Look for jtbd.json — project-local symlink first, then central ~/jtbd/ index.
JTBD_PATH=""

if [[ -f "$PROJECT_DIR/jtbd.json" ]]; then
  JTBD_PATH="$PROJECT_DIR/jtbd.json"
elif [[ -d "$HOME/jtbd" ]]; then
  # Pick the most recently modified jtbd.json under ~/jtbd/ (fast — typically <10 dirs).
  JTBD_PATH=$(find "$HOME/jtbd" -name "jtbd.json" -maxdepth 2 -print0 2>/dev/null \
    | xargs -0 ls -t 2>/dev/null \
    | head -1 || true)
fi

if [[ -z "$JTBD_PATH" ]] || [[ ! -f "$JTBD_PATH" ]]; then
  exit 0
fi

# Read the JSON content.
JTBD_CONTENT=$(cat "$JTBD_PATH")

# Build the context injection.
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

JTBD_ESCAPED=$(escape_for_json "$JTBD_CONTENT")
JTBD_PATH_ESCAPED=$(escape_for_json "$JTBD_PATH")

CONTEXT="<jtbd-context source=\"${JTBD_PATH_ESCAPED}\">\\n"
CONTEXT+="A JTBD interview has been completed for this project. The jtbd.json is below.\\n"
CONTEXT+="\\n"
CONTEXT+="INSTRUCTIONS FOR BRAINSTORMING:\\n"
CONTEXT+="1. Read the jtbd.json BEFORE asking clarifying questions.\\n"
CONTEXT+="2. SKIP questions already answered by the JSON:\\n"
CONTEXT+="   - What are you building? -> hook\\n"
CONTEXT+="   - Who is it for? -> jtbd.situation\\n"
CONTEXT+="   - What problem does it solve? -> problem.what_hurts\\n"
CONTEXT+="   - What does success look like? -> jtbd.outcome\\n"
CONTEXT+="   - What should it NOT do? -> guardrails[]\\n"
CONTEXT+="   - What are they using today? -> switch_forces.habit\\n"
CONTEXT+="   - How should it feel? -> needs.emotional[]\\n"
CONTEXT+="3. STILL ASK: technical constraints, architecture, scope/MVP.\\n"
CONTEXT+="4. Briefly revisit switch_forces.anxiety — confirm fears are addressed.\\n"
CONTEXT+="5. Surface open_questions[] as brainstorming priorities.\\n"
CONTEXT+="6. Use switch forces for approach selection:\\n"
CONTEXT+="   - Strong Push + weak Pull -> positioning problem\\n"
CONTEXT+="   - Strong Habit -> needs migration path, not greenfield\\n"
CONTEXT+="   - Strong Anxiety -> needs reversibility, trial mode, guarantees\\n"
CONTEXT+="7. Reference source: ${JTBD_PATH_ESCAPED}\\n"
CONTEXT+="\\n"
CONTEXT+="jtbd.json:\\n"
CONTEXT+="${JTBD_ESCAPED}\\n"
CONTEXT+="</jtbd-context>"

# Emit in Claude Code format.
printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "PreToolUse",\n    "additionalContext": "%s"\n  }\n}\n' "$CONTEXT"

exit 0
