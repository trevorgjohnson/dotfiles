---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Only trigger when user explicitly says "grill me" or asks to be interrogated about their design.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

If a question can be answered by exploring the codebase, explore the codebase instead.

## Tool usage

**AskUserQuestion** — use for every question that has finite, enumerable options (binary choices like sync/async, REST/GraphQL, monolith/microservice, or small fixed sets). Present your recommendation as the default. Do not use free-text prose questions when options can be enumerated.

**TaskCreate** — create one task per resolved decision branch as the interview progresses. This gives the user a concrete decision log they can review at the end. Mark each task `completed` as its branch is resolved. Use subjects like "Decision: Use REST over GraphQL" with the rationale in the description.
