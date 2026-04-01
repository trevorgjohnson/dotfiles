# Model Selection

Subagents — always pass `model` explicitly:
- **Opus** (`claude-opus-4-6`): architecture/design research, security audits, complex multi-step reasoning, long-horizon judgment
- **Haiku** (`claude-haiku-4-5-20251001`): parallelized search/read/grep, simple renames, narrow well-scoped tasks
- **Sonnet** (`claude-sonnet-4-6`): everything else (default)

Main session — suggest a switch at task start only, never mid-session:
- Suggest Opus for: full security audits, multi-phase architectural plans, complex agent pipelines, extended cross-file research
- Suggest Haiku for: quick lookups, trivial renames, narrow read-only inspections
