# Epic planning

Use this before any tickets are drafted. It covers getting from an epic idea to a ticket set ready for
[TICKET_PRACTICE.md](TICKET_PRACTICE.md) and creation via `acli`.

## Sequence

Breaking an epic into tickets moves through these gates in order. Do not skip ahead on an assumed structure.

1. Plan: work out what the epic accomplishes and the candidate ticket set.
2. Target-state consensus: write down the target state (see below) and get explicit agreement on it.
3. Size: check each candidate against the delivery window, gauge its ambiguity, and split, merge, or keep it
   (see below).
4. DAG: graph the dependencies between the sized tickets.
5. Create: draft and create the tickets per TICKET_PRACTICE.md. Put the agreed target state in the epic
   description and reference it from every story so each ticket is read against the same picture.

## Target state

The target state is what the code looks like once the last ticket merges. It is the finalized shape of the
system, not the ticket list, and it must be a stated consensus rather than a structure left implicit during
planning.

Build it in two layers, from the foundation up:

- State: every stateful thing the epic touches, treated alike whether we own it or not. Our table schemas are the
  usual case, since the database ends up running the code. External state counts the same way: BD Vault is in
  effect a schema we do not own and reach only through its API, and the blockchain behind the boats provider
  service is the same. Establish where state lives today and where it must live at the end.
- Services: the high-level APIs that connect those stateful things and move state between them. Which components
  exist, which are shared versus location-specific, who calls whom, in what order, and which statuses each step
  reads and writes.

Stop at that level. The minutiae below it belong to the developer.

### Writing the state layer

Readability beats density. One stateful thing per block, one field per line, and nothing that wraps. Mark each
block `new`, `changed`, or `external`, and give changed things only the delta. Relations use `-> table`, enums
list their members, and a one-line note under the block carries the rule that matters (who writes it, what stays
untouched). Never pack several tables into a two-column table with prose in the cells.

```
address (new)
  uuid
  procapUuid
  type: CONTAINER | GAS_WALLET
  address
  active
  listenDeposits
  canonical for BD/BTC addresses; EVM contract and gas_wallet columns untouched

gas_wallet (changed)
  + address_uuid -> address (nullable)
  BTC rows set address_uuid and leave address null; EVM rows are the reverse

deposit (new)
  uuid
  address_uuid -> address
  transaction_hash
  asset
  transfer_index
  amount
  chain_timestamp
  status: MINED | COMPLETED
  unique (transaction_hash, asset, transfer_index); bd-vault worker is the only writer

Bitcoin Core (external)
  blocks and confirmations; authoritative for both

BD Vault CWP (external)
  custody and address derivation; not read by detection
```

### Writing the services layer

Terse call chains, one flow per block, indented by who calls whom. Name the queue, cron, or RPC at each hop and
the status each step reads or writes. Branch on the discriminator that matters (`if btc`, `CONTAINER ->`).

```
# step 1 - create the transaction and nothing more
consumer -> processTransaction
  if btc, route to bd-vault-worker (forward castl data)
    bd-vault consumer -> bd-vault-worker.createTransaction
      shared transaction.createTransaction (PENDING)

# step 2 - broadcast the transaction
boats.tasks -> broadcastTransactions
  before doing anything on ETH, immediately queue an empty job to bd-vault-worker
    bd-vault consumer -> bd-vault.broadcastTransactions
      if PENDING/HOLD, bd-vault.make transaction (BROADCASTING)
      if BROADCASTING, bd-vault.get operation status (SUCCEEDED -> BROADCASTED, FAILED -> FAILED)
```

Neither example is the format. A restructure might call for a component or layering sketch instead. Pick whatever
depicts the end state most clearly for the epic at hand.

### Putting the target state in the epic body

The planning sketches above are for reaching consensus. The version that goes into the epic description is a
simplified rerender of them. Epics keep the usual `Context` / `Technical Context` / `AC` level-2 headings;
`Technical Context` holds two level-3 subsections, each a single `codeBlock`:

- `Target Flow`: one tree per step. The root is `STEP N - What it does`, the first child is the entry call chain,
  and the work hangs under it with `├─`/`└─` connectors. When a boats-api cron hands off to a worker, write it as
  `cron -> method -> signal (via queue) worker.method`. Keep queue names, worker/method names, and statuses. Drop
  ticket keys, Redis or cursor internals, RPC method names, and DB verbs (`upsert`); say what happens in plain
  words (`find blocks since the last one we processed`, `record as MINED`).
- `Target State`: one block per stateful thing as `(new) \`name\` DB table -> one-line purpose`, then only the
  columns a reader needs to follow the flows, each as `├─ column  what it is for`. Chain specifics and relations
  go in a trailing parenthetical hint (`(txid for Bitcoin)`, `(vout.n for Bitcoin)`, `(FK to new \`address\` table)`),
  never as types or constraint syntax.

```
STEP 1 - Queue new blocks
└─ boats-api cron -> monitorBlocks -> signal (via queue) bd-vault-worker.monitorBlocks
   ├─ find blocks since the last one we processed (plus any that failed)
   └─ queue a process-block job per block on bd-vault queue

STEP 2 - Catch deposits in a block
└─ bd-vault consumer -> bd-vault-worker.processBlock
   ├─ ignore transactions we sent ourselves
   └─ every payment to a vault address is a deposit, record as MINED
```

```
(new) `deposit` DB table -> generalization (and eventual replacement) of the existing *_deposit/*_received tables
├─ address         which watched address received it (FK to new `address` table)
├─ transactionHash the transaction it arrived in (txid for Bitcoin)
├─ transferIndex   where within the txn it was received (vout.n for Bitcoin)
└─ status          MINED -> COMPLETED
```

Pitch it for someone reading the epic cold: they should get the shape and the two notification paths without
knowing the codebase. BLOC-1042 carries the reference rendering.

### Naming mirrors the established flow

When a new chain or vendor pipeline mirrors an existing boats flow, reuse the existing names for the cron, queue
job, worker method, and shared services. The EVM deposit flow is `monitorBlocks` -> `process-block` ->
`processBlock` -> `monitorDeposits`, so the BTC flow is too; `process-deposit-block` or `processDepositBlock`
would be renaming for its own sake. Grep boats-backend for the EVM name before proposing one, and prefer sharing
the generic method over adding a chain-flavoured twin. The point is that every similar pipeline reads the same
way, so knowing one means knowing them all.

## Sizing

A ticket should be picked up, reviewed (change requests included), and merged within one to two days. This
delivery window is separate from its Fibonacci score: points measure how much uncertainty must be resolved before
the ticket is finished, not time or the volume of understood work.

Use the scale as an ambiguity gradient:

- `1`: the path and expected behavior are established; almost no uncertainty remains.
- `2`: a small, local choice or unknown remains.
- `3`: meaningful but bounded unknowns remain.
- `5`: the upper end of acceptable ambiguity; the outcome and AC are clear, and the remaining unknowns can still
  be resolved within the delivery window.

If the team cannot comfortably point a ticket at `5` or below without solutioning, it is not ready. Clarify it,
spike the uncertainty, or split it before pickup. Known mechanical work does not raise the score by itself.

For every candidate ticket, check both constraints against the target state and decide one of three things:

- Split when it cannot fit the delivery window or carries two seams that can merge independently (a migration and
  the command that uses it, a detector and a legacy-table backfill). Each half gets its own row in the DAG.
- Merge when two tickets are each a few hours and always land together, so a separate review would only add a
  round trip, provided the result still fits the window and remains comfortably pointable.
- Keep when it fits the window and its ambiguity is bounded enough to point.

Review surface can reveal ambiguity, but it is not the score itself. New tables, new queues, touched shared
services, and cross-worker routing often introduce unknowns; familiar mechanical changes may not. State the
provisional score and the split, merge, or keep decision next to each ticket so the user can push back before the
DAG is drawn. The team assigns the final score during refinement.
