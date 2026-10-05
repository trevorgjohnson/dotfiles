# Epic planning

For an epic breakdown, agree on what it accomplishes and the candidate work before drafting tickets.
Establish explicit target-state consensus, size the candidates, then graph dependencies between the sized tickets.
Draft and create only after those decisions, following [TICKET_PRACTICE.md](TICKET_PRACTICE.md) and its approval boundary.

The target state describes the system after the last ticket merges, rather than the ticket list.
Start with every stateful thing touched, including owned schemas, external custody APIs such as BD Vault, and blockchain state reached through the boats provider.
Establish where state lives now and where it must live at the end.
Then describe the services connecting it: shared versus location-specific components, callers, ordering, and statuses read or written.
Stop at those seams; leave implementation minutiae to developers.

Make state changes readable: one thing per block, one field per line, marked `new`, `changed`, or `external`, with only deltas for changed things.
Show relations, enum members, and consequential ownership or preservation rules.
Use short call chains for services, naming queues, crons, RPCs, statuses, and meaningful branches.
Choose a different sketch when it communicates the end state better.
The epic's reader-facing rendering keeps worker names, queue names, statuses, and necessary fields while translating low-level RPC, cursor, and DB details into plain flow language.
BLOC-1042 is the reference rendering.

When a new boats pipeline mirrors an established flow, inspect boats-backend and reuse its cron, job, worker, and shared-service names where applicable.
The EVM deposit flow is `monitorBlocks` -> `process-block` -> `processBlock` -> `monitorDeposits`; mirrored BTC flows should use those names too.
Prefer sharing a generic method over adding a chain-specific twin when the behavior permits it.

## Sizing

Each story or task must fit pickup, review including change requests, and merge within one to two days.
Fibonacci points measure uncertainty, not time or volume of understood work: `1` is established, `2` has a small local unknown, `3` has bounded meaningful unknowns, and `5` is the upper acceptable ambiguity within that window.
Clarify, spike, or split work that cannot comfortably be pointed at `5` or below without solutioning.
Known mechanical work and review surface do not raise the score by themselves.

Split work that exceeds the window or has independently mergeable seams, such as a migration and its consumer or a detector and a backfill.
Merge small tickets that always land together when the result still fits the window and ambiguity limit.
Otherwise keep the ticket.
Show each candidate's provisional score and split, merge, or keep decision for review before drawing the dependency DAG.
The team assigns final scores during refinement.
