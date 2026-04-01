#!/bin/bash
# Blocks psql write operations by default.
# Set ALLOW_DB_WRITES=1 in the command or environment to permit writes when explicitly prompted.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Only check psql commands
if ! echo "$COMMAND" | grep -qE '\bpsql\b'; then
  exit 0
fi

DML_PATTERNS=(
  "INSERT[[:space:]]"
  "UPDATE[[:space:]]"
  "DELETE[[:space:]]"
  "DROP[[:space:]]"
  "CREATE[[:space:]]"
  "ALTER[[:space:]]"
  "TRUNCATE[[:space:]]"
)

for pattern in "${DML_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -iqE "$pattern"; then
    if echo "$COMMAND" | grep -q "ALLOW_DB_WRITES=1" || [ "$ALLOW_DB_WRITES" = "1" ]; then
      exit 0
    fi
    echo "BLOCKED: psql write operation detected. All DB connections are read-only by default. Prefix the command with ALLOW_DB_WRITES=1 if the user has explicitly requested a write." >&2
    exit 2
  fi
done

exit 0
