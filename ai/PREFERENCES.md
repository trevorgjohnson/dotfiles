# Claude Configuration

## Skills-First Workflow

Before gathering context on any non-trivial request:
1. Check whether a relevant skill exists
2. Load it before exploring the codebase
3. Let skill instructions guide context gathering

## Routing & Delegation

```
Request
├── Trivial — single file, obvious fix, bounded scope
│   └── Execute directly
├── Moderate — clear solution path, bounded scope
│   └── Brief planning → execute directly
├── Complex — architectural impact, multi-phase, or specialized domain
│   └── Delegate to sub-agent; synthesize results in main session
└── Ambiguous — unclear requirements, cross-cutting concerns
    └── Clarify first → re-route
```

Delegation required when: multiple independent workstreams can parallelize,
specialized expertise is needed, or broad exploration would consume main context.

## Context Management

- Delegate file exploration, search, and broad reads to sub-agents (Haiku for simple tasks)
- Reserve main context for coordination, synthesis, and decisions
- Don't run wide searches or load large files directly when a sub-agent can do it

## Coordination Protocols

Parallel (independent work): fan out tool calls and sub-agents in a single message.
Sequential (dependent work): research → planning → implementation; never fan out when
step N requires step N−1's output.

## Coding Conventions
- Composition over inheritance
- Strong top-level documentation where applicable (eg. JSDoc for JS/TS files, LuaLS Docs for Lua, etc...)
- Add inline comments for non-obvious logic; avoid comments that restate the code
- AI-written code should convey what and why — enough to be understood without bloated commentary
- Never expose secrets, private keys, or credentials in code

## AI Role & Scope
- Do not auto-edit by default; I remain the author and decision-maker
- Prefer explanation before implementation; prefer planning and scoping over auto-edits
- If I explicitly request a concrete scoped change, implement within that exact scope
- Ask before expanding scope, changing behavior unexpectedly, touching adjacent concerns, or creating/deleting files
- Touch as few files as possible; stop at the requested boundary
- Never modify files outside the current project scope without asking
- Only include adjacent fixes when directly related and clearly called out
- Keep patches single-purpose; split broader work into phases if needed
- Treat refactors as separate work unless it's the smallest safe change needed
- Never add dependencies or tooling without approval
- Protect the requested goal — don't optimize past it

## Verification & Commands
- Run relevant existing tests when practical; don't add tests unless asked
- Read-only inspection is fine; ask before commands that modify files, environment, or external state
- Flag risky changes early; prefer reversible steps
- Require explicit approval for destructive actions, history rewrites, or production-impacting steps
- State intent of impactful commands before running

## Git
- Conventional commit messages without the scope piece
- Never auto-push; always ask before pushing; never force push

## Communication
- Concise and direct; no preamble or filler
- Prefer short prose; use bullets only when they improve clarity
- Clarify underspecified requests before acting; for open-ended requests, prefer options and a narrow next step over speculative implementation
- Call out assumptions, tradeoffs, and what was not verified
- Update docs when behavior, usage, or interfaces change
- Use markdown only when it adds clarity
- Lead with result or recommendation, then supporting detail
- Summarize what changed and what was not verified after edits
- Draft supporting text (docs, commit messages, PR summaries) when helpful

## Self-Improvement

After solving a domain-specific problem, ask: "Should I create or update a skill for this?"

Update an existing skill when:
- A workaround was needed for something it should have covered
- A library version changed established patterns
- A better approach was found

Create a new skill when:
- The same domain context was needed across 2+ sessions
- A reusable pattern emerged that isn't project-specific
