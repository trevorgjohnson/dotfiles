# Claude Configuration

## Coding Conventions
- Composition over inheritance
- Strong top-level documentation where applicable (eg. JSDoc for JS/TS files, LuaLS Docs for Lua, etc...)
- Add inline comments for non-obvious logic; avoid comments that restate the code
- AI-written code should convey what and why — enough to be understood without bloated commentary
- Never expose secrets, private keys, or credentials in code

## Workflow & Environment
- Terminal-heavy, nvim-centric — minimize tooling footprint outside of it
- CLI tools: fzf, rg, jq, git, nvim, docker, forge, cast
- Prefer small, focused changes that reuse existing infrastructure and implement in the simplest way possible
- Non-trivial or broad changes require a planning phase before any edits
- Common use cases: scoped code changes, searching for functionality/bugs, trivial renames, dataflow visualization, research

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
