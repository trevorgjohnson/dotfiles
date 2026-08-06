---
name: document
description: >-
  Researches a flow or system in one or more codebases using subagents, verifies every claim against
  source in a fresh context, then produces a single self-contained HTML article that documents the
  flow with visualizations (pipeline, sequence, and state diagrams) and a concrete worked example. Use when the user wants a durable,
  trustworthy reference for how something actually works end to end, not a quick verbal answer.
  Trigger on `/document`.
argument-hint: '<flow or system to document> [repo(s) / scope / audience]'
triggers:
  - /document
---

# Document

You are an orchestrator. Keep your own context lean: delegate all code exploration and verification to
subagents and synthesize their structured returns. Do not read whole repos or subagent transcript
files yourself.

The deliverable is a single file in the working directory: `<subject>.html`, a self-contained HTML
article documenting the flow with visualizations.

Hold the subagents' structured findings in your own context as you go and reuse them across the build
and verification steps rather than re-fetching. You are the cache; there is no separate notes file.

The bar: every non-trivial claim is traceable to real source (file:line) and has survived a
fresh-context verification pass. A wrong anchor or message format is worse than an omitted one.

## Quality bar

- **Grounded in source, never memory.** All facts come from the code via subagents, not parametric
  guesses. Exact names, signatures, enums, queue/job names, message formats, and config values are the
  hallucination-prone parts, get them from the code.
- **One concrete worked example.** Carry a single realistic scenario with real values pulled from the
  code (for example an ETH withdrawal) through the whole article. It is the spine, not garnish.
- **Show the flow.** Prefer diagrams for anything spatial or step-connected: a service/pipeline map, a
  numbered sequence, a status/state machine, a message/field anatomy.
- **Why, not just what.** Where a design choice is non-obvious, a short beat on what it prevents or why
  it is shaped that way. This is what stops shallow understanding.
- **Verify before finalize.** A fresh subagent fact-checks the article against source and you fix
  what it flags before declaring done.

## Step 1 - Scope

Parse the subject and any scope notes from the argument. Identify the flow or system and which repo(s)
are involved. This can be a single repo or many.

Map the layers/boundaries the flow crosses (services, modules, transports, on-chain, etc.). If a
`triage`-style layer map or an `AGENTS.md`/`CLAUDE.md` exists in the repos, use it to seed the scope.

Before dispatching, confirm with the user, in your own words:
- what flow you are documenting and its boundaries,
- which repo(s)/areas you will explore, and
- what each subagent will specifically do.

Keep the scope narrow. Start with the core happy path; expand only if needed. If the ask is too broad,
ask the user to narrow it rather than boiling the ocean.

## Step 2 - Research fan-out (delegate; keep context lean)

Use the **smallest model that can do the job**. For code search that means the **Explore agent
(Haiku)**; reserve heavier models for genuine reasoning.

- Dispatch **one targeted subagent per area/repo/boundary**, in parallel. Give each a specific,
  file-and-function-level question, not "go read this repo."
- Instruct each to return a **structured summary with `file:line` anchors**: entry points, the
  step-by-step logic, key data structures/types/enums, and the exact handoffs to adjacent areas.
  Findings only, never raw file dumps.
- **Second round for the seams.** After the first round, dispatch focused follow-ups to nail the exact
  cross-boundary details the worked example needs: function signatures, queue/job/mutation names,
  message/byte formats, status enums, and config values (with their real defaults). Precision here is
  what makes the example correct.
- Rely on each subagent's returned summary. Do not open the transcript output files.

## Step 3 - HTML article (self-contained)

**Load the `deliverable-style` skill and follow it.** It is the single source of truth for the
palette and token block, type, layout and measure, functional color, callouts, code panels, math,
figures, charts, and the self-contained guarantee. Do not restate or fork any of it here.

This is a utilitarian-but-polished reference doc, not an editorial landing page: strong hierarchy,
real information design, tasteful restraint.

The subject drives **layout, which diagrams to build, and how semantic color is assigned**, not the
palette or type. Assign each accent a fixed role for the subject (for example a status ramp:
neutral/in-flight/signing/success/failure) and hold it consistent across prose, diagrams, and pills
so the same idea is the same color everywhere.

### Figures for a flow doc

Beyond the general figure contract, these are the high-value ones here:

- **Service/pipeline map** - the boundaries the flow crosses and the transport on each hop.
- **Numbered sequence** - what happens in order, with the responsible layer tagged on each step.
- **Status/state machine** - the lifecycle, color-coded by phase, with off-ramps shown.
- **Message/field anatomy** - color-code each field and trace it across the messages it flows through.
- **Worked-example tables** - field to value to note, with the real values.

Length follows the subject; do not pad.

## Step 4 - Verify (fresh context; iterate on doubt)

Dispatch a **fresh-context subagent** (one that has not seen the research) to fact-check the article
against real source. Give it the file path and an explicit, numbered checklist of the specific claims
to verify, ordered by risk. Tell it to trust the code, not the documents, and to return
per claim: **CONFIRMED**, **WRONG** (with the correct value + `file:line`), or **UNVERIFIABLE** (why).

Prioritize the claims most likely to be wrong: message/byte formats, function signatures, queue/job and
mutation names, enum values, config defaults and units, and any cross-boundary contract.

Fix every WRONG item in the article. If corrections are substantial, re-verify. Do not finalize
with unresolved doubts, and surface any UNVERIFIABLE claims to the user as open questions.

## Step 5 - Deliver

- Open the HTML: `open <file>` (macOS) or `xdg-open <file>` (Linux). If you regenerate it, reopen so
  the user sees the new version (the browser will not auto-refresh a file change).
- State the file path.
- Summarize the flow briefly and list any open questions the verification could not close.

## Notes

- Keep the orchestrator lean. Never read whole repos or transcript files yourself; dispatch and
  synthesize. Right model for the job.
- Accuracy over polish. A tightly-scoped, verified doc beats a broad, plausible-sounding one.
- The worked example is the spine of the article. If a section cannot advance or reference it,
  question whether it belongs.
- For the full HTML styling contract (callouts, functional color, code panels, SVG technique), defer to
  the `deliverable-style` skill so every deliverable stays consistent.
