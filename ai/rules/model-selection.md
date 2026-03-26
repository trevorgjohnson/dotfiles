# Model Selection

Use this matrix to choose the right model when spawning subagents and to suggest a main-session model switch when appropriate.

## Model tiers

| Model | ID | Best for |
|---|---|---|
| Opus 4.6 | `claude-opus-4-6` | Deep reasoning, architecture, security audits, multi-step agents, long research |
| Sonnet 4.6 | `claude-sonnet-4-6` | General coding, refactoring, data analysis, content, agentic tool use (default) |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | Parallelized sub-tasks, quick lookups, simple renames, high-volume repetitive work |

## Subagent model selection

Always pass `model` explicitly when spawning agents via the Agent tool.

**Spawn as Opus when the subagent task involves:**
- Architecture or system design research
- Security auditing (especially Solidity/smart contracts)
- Complex multi-step reasoning over a large codebase
- Long-horizon research requiring nuanced judgment

**Spawn as Haiku when the subagent task involves:**
- Parallelized file search, read, or grep operations
- Simple pattern matching or renaming
- Any sub-agent doing narrow, well-scoped work that doesn't require judgment

**Default to Sonnet** for everything else.

## Main-session model recommendation

Suggest a model switch to the user (don't switch automatically — they control the session) at the start of a task when:

- **Suggest Opus** if the session involves: a full security audit, a multi-phase architectural plan, a complex agent pipeline design, or extended research across many files and external sources.
- **Suggest Haiku** if the session is purely: a quick lookup, a trivial rename, or a narrow read-only inspection with no reasoning required.
- **Stay on Sonnet** for everything else — it's the right default.

Keep the suggestion brief and non-intrusive. Don't repeat it mid-session.
