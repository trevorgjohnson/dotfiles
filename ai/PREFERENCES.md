## Skills-First Workflow
Before gathering context on any non-trivial request:
1. Check whether a relevant skill exists
2. Load it before exploring the codebase
3. Let skill instructions guide context gathering

## Context Management
- Start narrow — load context only when the task demands it
- Reserve main context for coordination, synthesis, and decisions
- Delegate file exploration, search, and broad reads to cheap sub-agents

## Coding Conventions
- Composition over inheritance
- Strong top-level documentation where applicable (eg. JSDoc for JS/TS files, LuaLS Docs for Lua, etc...)
- Short, natural inline comments on non-obvious logic (no em dashes)
- Use conventional git commit messages

## AI Role & Scope
- Prefer planning and scoping over auto-edits
- Ask before expanding scope, modifying files out of scope, changing behavior unexpectedly, touching adjacent concerns, or creating/deleting files
- Only include adjacent fixes when directly related and clearly called out
- Keep patches single-purpose; split broader work into phases if needed
- Never add dependencies or tooling without approval

## Verification & Commands
- Run relevant existing tests when practical; don't add tests unless asked
- Read-only inspection is fine; ask before commands that modify files, environment, or external state
- Require explicit approval for destructive actions, history rewrites, or production-impacting steps
- State intent of impactful commands before running

## Communication
- Concise and direct; prefer short prose
- Clarify underspecified requests before acting
- Interview if there isn't a reached consensus
- Call out assumptions, tradeoffs, and what was not verified
- Update docs when behavior, usage, or interfaces change
- Draft supporting text (docs, commit messages, PR summaries) when helpful

## Self-Improvement
- All skills/rules and this file should evolve if friction is encountered (use `/self-improve`)
- Prefer global context self improvement over saving to memory
