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

Load the `artifact-design` skill for calibration. This is a utilitarian-but-polished reference doc, not
an editorial landing page: strong hierarchy, real information design, tasteful restraint.

The output is one `.html` file with **all CSS, JS, and SVG inlined, no CDN, no network fetches**. It
must render offline and print cleanly. Wide content (tables, code, diagrams) lives in its own
`overflow-x:auto` container so the page body never scrolls sideways.

This skill borrows its HTML output contract from the `/explain` skill (see that skill for the full
detail on functional color, callouts, code/long-value handling, and SVG figures). Reuse it, with these
points held firm:

### Styling default (house style)

Catppuccin Mocha, dark, **Mauve** as the primary accent, **Iosevka Nerd Font** throughout (the doc
reads mono; that is intended). Embed this token block as `:root` and draw every color from it:

```css
:root{
  --crust:#11111b; --mantle:#181825; --base:#1e1e2e;
  --surface0:#313244; --surface1:#45475a; --surface2:#585b70;
  --overlay0:#6c7086; --overlay1:#7f849c; --overlay2:#9399b2;
  --subtext0:#a6adc8; --subtext1:#bac2de; --text:#cdd6f4;
  --pink:#f5c2e7; --mauve:#cba6f7; --red:#f38ba8; --peach:#fab387;
  --yellow:#f9e2af; --green:#a6e3a1; --teal:#94e2d5; --sapphire:#74c7ec;
  --blue:#89b4fa; --lavender:#b4befe;
  --bg:var(--base); --panel:var(--mantle); --ink:var(--text); --muted:var(--subtext0);
  --accent:var(--mauve); --rule:var(--surface0); --hl:rgba(203,166,247,.14);
  --font:"Iosevka Nerd Font","IosevkaTerm Nerd Font","Iosevka NF","Iosevka",
         ui-monospace,"Cascadia Code",Menlo,monospace;
}
body{font-family:var(--font);background:var(--bg);color:var(--ink)}
a{color:var(--mauve)}
```

The subject drives **layout, which diagrams to build, and how semantic color is assigned**, not the
palette or type. Assign each accent a fixed role for the subject (for example a status ramp:
neutral/in-flight/signing/success/failure) and hold it consistent across prose, diagrams, and pills so
the same idea is the same color everywhere. Keep the accent as Mauve; do not let the state ramp fight
it.

### Readability

Constrain running prose to a comfortable measure (a `--measure` of roughly 70-80ch for mono) in a
centered column; let full-bleed diagram and table blocks break wider. Lay out sibling groups with
flex/grid `gap`, not per-element margins. Use `font-variant-numeric:tabular-nums` wherever digits align
in columns. Watch selector specificity so component styles do not silently cancel each other out.

### Visualizations (hand-built, CSP-safe)

The Artifact CSP and the offline guarantee block external scripts, so **do not use mermaid or any CDN
library**. Build diagrams by hand with CSS (flex/grid) or inline static SVG with computed coordinates.
The high-value figures for a flow doc:

- **Service/pipeline map** - the boundaries the flow crosses and the transport on each hop.
- **Numbered sequence** - what happens in order, with the responsible layer tagged on each step.
- **Status/state machine** - the lifecycle, color-coded by phase, with off-ramps shown.
- **Message/field anatomy** - color-code each field and trace it across the messages it flows through.
- **Worked-example tables** - field to value to note, with the real values.

Give every figure a `<figure>`/`<figcaption>`, make it responsive, and respect
`prefers-reduced-motion` for any animation. Length follows the subject; do not pad.

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
  the `/explain` skill so the two stay consistent.
