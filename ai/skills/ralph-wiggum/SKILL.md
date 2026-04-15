---
name: ralph-wiggum
description: Autonomous verify-until-done execution loop. Agent doesn't stop when it thinks it's done — it stops when work is objectively verified. Supports multiple concurrent sessions (one per plan). Use when the user wants to run a task autonomously until all tests pass, a plan is complete, or a verification command exits 0. Sits at the end of the skill pipeline: write-a-prd → prd-to-plan → ralph-wiggum.
---

# Ralph Wiggum

Autonomous execution layer. Agent quits when work is verified, not when it thinks it's done.

## When to Use

- 1–3 phases, bounded risk, objective verify command exists (tests pass/fail, CI green)
- Use `phasic-plan` instead when phases need human approval or can't be verified programmatically
- Use parallel sessions for independent workstreams

## Pipeline Position

```
grill-me (optional)
  └─► write-a-prd          → ~/.claude/prds/<feature>/prd.md
        └─► prd-to-plan    → ~/.claude/plans/<feature>.md  ← plan_path for ralph-wiggum
              └─► ralph-wiggum  (this skill — executes autonomously)
```

**Upstream**: `prd-to-plan` produces the plan file (`~/.claude/plans/<feature>.md`) that ralph-wiggum executes. The acceptance criteria checkboxes in that plan are what the agent marks complete.

**Verification**: Use `/verify` to identify the right verify command for the project before setting up the loop.

**Alternative**: Use `phasic-plan` instead of ralph-wiggum when phases need human approval gates rather than autonomous execution.

**Complementary**: Run `/tdd` within the loop — the implementation prompt can instruct the agent to write tests first before marking tasks complete.

## Prerequisites

Register the stop hook once in your agent's settings. For Claude Code, add to `~/.claude/settings.json`:

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "~/.claude/hooks/ralph-wiggum.sh"
      }
    ]
  }
]
```

Make executable once:
```bash
chmod +x ~/.claude/hooks/ralph-wiggum.sh
```

## How Multi-Session Works

Each plan gets its own state file: `~/.claude/ralph-wiggum/{plan-slug}.json`.

The stop hook fires per session. It scans all active state files and identifies which plan the current session owns by checking whether the `plan_path` appears in the session's transcript. Sessions are decoupled — no session ID registration needed.

## Quick Start

1. **Create a state file** (named after the plan):
   ```bash
   mkdir -p ~/.claude/ralph-wiggum
   cat > ~/.claude/ralph-wiggum/my-feature.json <<EOF
   {
     "plan_path": "/abs/path/to/my-feature.md",
     "verify_command": "npm test",
     "completion_promise": "TASK_COMPLETE",
     "max_iterations": 25,
     "iteration": 0
   }
   EOF
   ```

2. **Start a fresh session** — paste this prompt:
   ```
   Study the plan at /abs/path/to/my-feature.md.
   Pick the single most important uncompleted task.
   Implement it following existing patterns.
   Run: npm test

   - Tests pass → mark task complete in plan (check the checkbox), commit
   - Tests fail → fix and rerun
   - All tasks done and tests green → output: TASK_COMPLETE
   ```

3. **The hook takes over** on every stop:
   - No `TASK_COMPLETE` → injects continuation prompt, agent keeps going
   - `TASK_COMPLETE` present → runs verify command
     - Passes → deletes state file, loop ends
     - Fails → injects failure output, agent fixes and retries

4. **Cancel anytime**:
   ```bash
   rm ~/.claude/ralph-wiggum/my-feature.json
   ```

## Workflows

### /ralph-wiggum setup

Use `AskUserQuestion` to ask for the plan file path (default: `~/.claude/plans/`).

Once the plan path is known, read its `## Execution` block to pre-fill:
- `verify_command` — from "Verify command" line
- `completion_promise` — from "Completion promise" line (default: `TASK_COMPLETE`)
- `max_iterations` — from "Max iterations" line (default: `25`)

If the `## Execution` block is missing or incomplete, ask for the missing values. Run `/verify` if the verify command is unknown.

Write `~/.claude/ralph-wiggum/{slug}.json` (slug = plan filename without extension), then print the start prompt.

### /ralph-wiggum list

```bash
ls ~/.claude/ralph-wiggum/*.json 2>/dev/null | while read f; do
  echo "$(basename "$f" .json): iteration $(jq '.iteration' "$f")/${$(jq '.max_iterations' "$f")}"
done
```

### /ralph-wiggum cancel [plan-slug]

```bash
rm -f ~/.claude/ralph-wiggum/{plan-slug}.json
```

## Failure Modes

| Symptom | Cause | Fix |
|---|---|---|
| Infinite loop | Impossible task or broken verify cmd | Lower `max_iterations`; fix verify command |
| Stops too early | Promise output before work is done | Tighten verify command; add more tests |
| Context bloat | Many failures fill context window | Lower `max_iterations`; split plan into phases |
| Feature invention | Vague plan | Add explicit scope + "do NOT" exclusions to plan |
| Wrong plan matched | Two plans share a path fragment | Use fully unique absolute paths |

## Key Principle

**Always give the agent a way to verify its work.**
No objective verification → infinite loop or premature stop.
Objective verification → reliable iteration to genuine completion.
