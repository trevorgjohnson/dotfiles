#!/bin/bash
# Ralph Wiggum stop hook — blocks the agent from stopping until work is verified.
# Supports multiple concurrent sessions: each plan has its own state file.
# State dir: ~/.claude/ralph-wiggum/*.json
# Registered under the agent's Stop hook configuration.
#
# TODO: make state dir generic (e.g. ~/.config/dotfiles/ai/ralph-wiggum/) so other agents can share it

STATE_DIR="$HOME/.claude/ralph-wiggum"

# No sessions active — allow stop.
shopt -s nullglob
STATE_FILES=("$STATE_DIR"/*.json)
shopt -u nullglob
[ "${#STATE_FILES[@]}" -eq 0 ] && exit 0

# Parse stdin
INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

# Guard against recursion
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

# Find the state file whose plan_path appears in this session's transcript.
# Each session is linked to its plan by the transcript content, not session_id.
ACTIVE_STATE=""
for f in "${STATE_FILES[@]}"; do
  PLAN_PATH=$(jq -r '.plan_path // ""' "$f")
  [ -z "$PLAN_PATH" ] && continue
  if grep -qF "$PLAN_PATH" "$TRANSCRIPT_PATH" 2>/dev/null; then
    ACTIVE_STATE="$f"
    break
  fi
done

# This session isn't running a Ralph loop — allow stop.
[ -z "$ACTIVE_STATE" ] && exit 0

# Read state
PLAN_PATH=$(jq -r '.plan_path' "$ACTIVE_STATE")
VERIFY_CMD=$(jq -r '.verify_command' "$ACTIVE_STATE")
COMPLETION_PROMISE=$(jq -r '.completion_promise // "TASK_COMPLETE"' "$ACTIVE_STATE")
MAX_ITER=$(jq -r '.max_iterations // 25' "$ACTIVE_STATE")
ITERATION=$(jq -r '.iteration // 0' "$ACTIVE_STATE")

# Extract last assistant message from transcript (handles JSON array and JSONL)
LAST_MSG=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  LAST_MSG=$(jq -r '[.[] | select(.role == "assistant")] | last | .content // ""' "$TRANSCRIPT_PATH" 2>/dev/null)
  if [ -z "$LAST_MSG" ] || [ "$LAST_MSG" = "null" ]; then
    LAST_MSG=$(grep -o '"role":"assistant"[^}]*' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1 | jq -r '.content // ""' 2>/dev/null || echo "")
  fi
fi

# Increment iteration
NEXT_ITER=$((ITERATION + 1))
jq ".iteration = $NEXT_ITER" "$ACTIVE_STATE" > "${ACTIVE_STATE}.tmp" && mv "${ACTIVE_STATE}.tmp" "$ACTIVE_STATE"

# Enforce max iterations
if [ "$NEXT_ITER" -gt "$MAX_ITER" ]; then
  echo "Ralph Wiggum: max iterations ($MAX_ITER) reached for $(basename "$ACTIVE_STATE"). Stopping." >&2
  rm -f "$ACTIVE_STATE"
  exit 0
fi

# Completion promise found — run verification
if echo "$LAST_MSG" | grep -qF "$COMPLETION_PROMISE"; then
  VERIFY_OUTPUT=$(eval "$VERIFY_CMD" 2>&1)
  VERIFY_EXIT=$?

  if [ "$VERIFY_EXIT" -eq 0 ]; then
    rm -f "$ACTIVE_STATE"
    echo "Ralph Wiggum complete: $(basename "$ACTIVE_STATE" .json) verified after $NEXT_ITER iteration(s)." >&2
    exit 0
  else
    printf 'Completion promise found but verification failed. Fix the failures then output %s again.\n\nVerification output:\n%s\n\nPlan: %s' \
      "$COMPLETION_PROMISE" "$VERIFY_OUTPUT" "$PLAN_PATH"
    exit 2
  fi
fi

# No completion promise — inject continuation prompt
printf 'Continue the plan at %s (iteration %d/%d).\n\nPick the single most important uncompleted task. Implement it. Run: %s\n\n- Tests pass → mark task complete in plan, commit\n- Tests fail → fix and rerun\n- All tasks done → output: %s' \
  "$PLAN_PATH" "$NEXT_ITER" "$MAX_ITER" "$VERIFY_CMD" "$COMPLETION_PROMISE"
exit 2
