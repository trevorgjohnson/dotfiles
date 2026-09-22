# Ticket writing practice

Use this guidance when drafting Jira epics, stories, tasks, or spikes for review. Getting from an epic idea to a
ticket set ready for drafting is covered in [EPIC_PLANNING.md](EPIC_PLANNING.md).

## Titles

- Prefix the summary with the target application, not necessarily the Jira project key.
- On the shared BLOC board, use `[BOATS]` for boats work and `[COWS]` for cows work.
- Follow the prefix with a short imperative verb phrase describing one outcome, capitalized
  (`[BOATS] Create new generic deposit table`, `[BOATS] Complete caught BTC deposits`).

## Epics

Write epics for Product, Project, and QA readers. Keep them high-level and flow-oriented.

- Include `Context` and `AC`; omit `Technical Context`.
- Explain the user or system flows the epic enables and the observable lifecycle of each flow.
- State how the full flow will be proven before the epic closes.

## Stories and tasks

Use `Context`, `Technical Context`, and `AC`.

- `Context` explains why the ticket exists and where it fits in the larger flow.
- Write `Context` in plain, conversational language. Lead with the immediate operational need, then explain how
  the chosen direction supports the longer-term architecture when that rationale matters.
- `Technical Context` reads as a walkthrough of the flow, in the order the code will run it ("Within each
  processing function for a given block: grab the addresses, call `getblock`, check each `vout`..."). Name the
  concrete seams at each hop: the queue (`boats-collect-deposit-received`), the RPC call and its arguments
  (`getrawtransaction(true, 2)`), the cron and worker (`boats-api.monitorDeposits()` wakes `bd-vault-worker`).
  Leave implementation structure and coding taste to the developer.
- Point at the existing flow the work should mirror ("this should feel extremely familiar to the EVM deposit flow,
  even sharing functions") rather than re-describing it.
- Cross-reference sibling tickets inline where one hands off to another (`the consumer of which will be created
  in BLOC-1045`).
- `AC` starts with observable flows written as "when X happens, Y should Z", then includes only the technical
  invariants needed to verify correctness. Carry-over behavior from the existing flow gets one bullet ("the
  following should still be the same from the EVM flow") with the specifics nested under it.
- A closing line may warn the tester about a gotcha (a live CASTL rejecting the new payload, a manual Redis rewind
  to test retries).

Prefer language such as: "BOATS listens for, catches, records, and notifies CASTL about a deposit when it becomes
`MINED`, then notifies CASTL again when it becomes `COMPLETED`."

## Tone

Conversational and direct, as if explaining the work to a teammate at their desk. Contractions, short asides in
parentheses, and "feel free to log a warning" are fine. Rhetorical framing is fine in `Context` ("otherwise how
will it know what to listen for?"). Keep the formality for identifiers, states, and queue names, which are always
exact and backticked.

## Brevity

- Target three root bullets per section; fewer is better.
- Five root bullets is a soft maximum. A walkthrough `Technical Context` may run longer when every bullet is a
  distinct step in the flow.
- Use nested bullets only when one requirement has necessary variants, such as separate customer and gas-wallet
  state transitions.
- Use emphasis or a Jira note panel sparingly for a caveat that would interrupt the main flow, such as an address
  normalization hazard, or for the forward-looking intent behind a change (what a new table will eventually replace).
- Italic parentheticals carry short asides on a bullet: current placeholder values, chain-specific units, plain
  restatements of a constraint (`(aka. inserting the same tuple twice should throw)`).
- Column and relation lists use `column` → `target` for foreign keys and nest per-chain variants under the column.
- Consolidate related criteria instead of enumerating every implementation step or test case.

## Scope and developer freedom

- Assume assignees are domain experts. Explain only behavior that is new or different from established flows and
  framework patterns.
- Describe the required result, not the implementation recipe.
- Omit rejected alternatives, speculative future work, conversation history, and lists of what not to build.
- Routine test coverage goes without saying. Mention testing only when verification is the ticket's deliverable or
  a non-obvious behavior needs explicit proof.
- Keep required status transitions, event destinations, uniqueness rules, and externally visible failure behavior,
  using plain flow language unless an exact technical term matters.

## Sizing

Every story or task should be picked up, reviewed, and merged within one to two days. Fibonacci points measure
how much uncertainty must be resolved within that window, not the volume of understood work. A `5` is the upper
end of acceptable ambiguity. If a story cannot be comfortably pointed at `5` or below, clarify, spike, or split it
before pickup. See the sizing section of [EPIC_PLANNING.md](EPIC_PLANNING.md).

## Review and creation

- Draft the complete ticket set in Markdown when batch review is useful.
- Keep dependencies short and outcome-oriented.
- Search Jira for duplicates before creation.
- Present the final ticket text for explicit approval before creating or updating Jira items.
