# Ticket writing practice

Prefix titles with the target application and a short capitalized imperative phrase describing one outcome.
On the shared BLOC board, use `[BOATS]` or `[COWS]` according to the codebase receiving the change.
Avoid colons, dashes, subtitles, and lists of outcomes in titles.

Use ADF level-2 headings `Context`, `Technical Context`, and `AC` for stories and tasks.
Ordinary epics use `Context` and `AC`, written for Product, Project, and QA readers, explaining enabled flows and how the full flow will be proven.
For epics developed through [EPIC_PLANNING.md](EPIC_PLANNING.md), add a level-2 `Technical Context` between `Context` and `AC`.
Its level-3 `Target Flow` and `Target State` subsections each hold a concise code block showing the agreed end state.
Reference that target state from each child ticket.

`Context` explains the immediate operational need and why it matters, including architectural rationale only when useful.
`Technical Context` walks the changed flow in execution order, naming concrete queues, RPC arguments, crons, workers, and shared services at the relevant seams.
Point to established flows to mirror and sibling tickets at handoffs; leave implementation structure to the developer.
`AC` starts with observable “when X happens, Y should Z” flows, then includes the technical invariants needed to prove correctness.
Consolidate unchanged behavior from an established flow into one bullet with necessary specifics beneath it.
Preserve required status transitions, event destinations, uniqueness rules, and externally visible failure behavior.
Mention tests only when verification is the deliverable or a non-obvious behavior needs explicit proof.

Write conversationally and directly for domain experts.
Identifiers, flags, files, configuration keys, states, and queue names must be exact and backticked, with ADF `code` marks.
Match boats-backend wording when quoting logs or errors.
Use no em dashes.
Target three root bullets per section, with five a soft maximum; a flow walkthrough may need more distinct steps.
Nest only necessary variants, consolidate related criteria, and use short asides or note panels sparingly for real gotchas.
Column relations use `column` → `target`, with chain variants nested beneath the column.
Omit rejected alternatives, speculative future work, conversation history, and implementation recipes.

Stories and tasks must be picked up, reviewed, and merged within one to two days, with ambiguity comfortably pointable at `5` or below.
Use [EPIC_PLANNING.md](EPIC_PLANNING.md) for sizing and decomposition.
Draft a complete ticket set in Markdown when batch review is useful, keeping dependencies short and outcome-oriented.
Search for duplicates and present final text for explicit approval before creating or updating Jira items.
