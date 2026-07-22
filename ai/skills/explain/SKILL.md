---
name: explain
description: >-
  Produces a single, self-contained, beautiful HTML document that teaches ONE subject from the
  ground up, in the style of a great long-form technical explainer (bottom-up sequencing, a running
  worked example with real numbers, "why this design choice" reasoning, diagrams, and adaptive
  sourcing). Use when the user wants a standalone teaching artifact they can keep, reread, and print,
  not a quick verbal answer. Trigger on `/explain`.
argument-hint: '<subject to explain> [audience / prior knowledge / depth notes]'
triggers:
  - /explain
---

# Explain

Build a self-contained HTML document that teaches one subject well enough that a motivated reader
walks away actually understanding it, not just having read about it. The output is a single `.html`
file on disk, styled Catppuccin Mocha, opened in the browser. The bar is the great long-form
explainer: motivate before you formalize, build strictly bottom-up, anchor everything in one running
example with real numbers, and explain not just what a thing does but why it was built that way.

The quality bar, distilled from the reference explainers this skill was built against:

- **Motivation before mechanism.** Open with a concrete scenario or a real gap in the reader's
  understanding. Earn the math before you show it.
- **Strict bottom-up sequencing.** Every concept is a prerequisite for the next. No forward
  references. If section 4 needs an idea, section 3 taught it.
- **One running example, accreted.** Pick a single concrete, visualizable scenario with real
  numbers and carry it through the whole document, building on prior state rather than resetting.
- **Why, not just what.** After each mechanism, a short "why this choice" beat: what breaks if you
  do it the obvious way, what attack or failure the design prevents. This is what stops cargo-cult
  understanding.
- **Intuition first, rigor deployed selectively.** Lead with the intuition; bring in formal
  treatment where it earns its place. Analogies only when they genuinely make it clearer.

## Step 1 - Scope

Parse the subject and any audience/depth notes from the argument.

Proceed directly to building if the goal is clear. Ask the user first ONLY when one of these is
genuinely ambiguous:

- **Audience / prior knowledge** - what can you assume they already know? (Calibrates where the
  bottom-up sequence starts.)
- **The one thing** - the single idea they must walk away understanding. Everything serves this.
- **Depth** - a working intuition, or a rigorous treatment they could implement from.

Keep questions to the minimum that unblocks you. Do not interrogate; a sentence or two of
clarification is usually enough. If the subject and intent are obvious from the prompt, skip this
step entirely.

## Step 2 - Ground (adaptive sourcing)

Choose the sourcing mode from the subject, not by habit:

- **Technical / factual** (protocols, algorithms, specs, APIs, math, anything with exact values or a
  canonical definition): research FIRST. Use WebSearch/WebFetch to pull the primary sources (specs,
  papers, RFCs, official docs) before writing. Never trust parametric knowledge for exact constants,
  algorithm steps, or security claims - these are the hallucination-prone parts.
- **Conceptual / well-trodden** (general ideas, intuitions, history): parametric knowledge is fine,
  with citations where you're confident.

When you research, cite inline at the point each non-trivial claim is made (a real link), and close
the document with a **References** list of the primary sources. Prefer the highest-trust source
available (spec > paper > official docs > reputable secondary > forum). Link the reader to one
**primary source to go deeper** in the recap.

## Step 3 - Design the running example (and verify it)

Pick one concrete, visualizable scenario with **real, computed numbers** and make it the spine of the
document. Named actors doing a tangible thing beat abstract symbols. Choose an anchor that genuinely
fits the mechanics; never bend the story in a way that misrepresents the concept.

Use small, hand-checkable numbers where the topic allows (the reference explainers work in `mod 23`
or `mod 97` precisely so the reader can verify each step by hand). The example accretes: each section
spends its new concept on the same scenario, building on the prior state, until by the end it is
fully assembled.

**Correctness guard (required).** Before the document is finalized, actually compute every number in
the running example and confirm the equations hold. Do the arithmetic in a scratch script (or a
subagent) rather than eyeballing it. A worked example with a wrong intermediate value is worse than
no example. If a value cannot be verified, do not present it as fact.

## Step 4 - Structure of the document

Every explain doc follows this skeleton. Adapt section names to the subject, keep the order.

1. **Title + one-line framing** - what this teaches and who it's for.
2. **Hook / motivation** - the concrete scenario or the gap. Why should the reader care, in real
   terms, before any formalism.
3. **What you'll understand + prerequisites** - a short map of where this is going and what the
   reader is assumed to know. Sets the floor of the bottom-up sequence.
4. **The concept sequence** - the body. A strict bottom-up chain of sections. Each section:
   - **Intuition** - the plain-language idea, often with the running example.
   - **Mechanics** - the precise statement: equation, algorithm, definition.
   - **Why this choice** - what breaks under the naive alternative, what this prevents.
   - **Running example** - advance the one scenario one step, with verified numbers.
5. **Misconceptions / gotchas** - the specific wrong mental models a reader tends to form, corrected.
6. **Recap + go deeper** - a tight synthesis, the single best primary source to read next, and a
   **References** list if you researched.

Length follows the concept, not a target. A small topic gets a short doc; sprawl only when the
subject genuinely demands it. Do not pad. One tightly-scoped subject per document; if it's genuinely
too big, say so and propose splitting into linked docs rather than producing a bloated one.

## Step 5 - Visuals and interactivity

Favor visuals for anything spatial, structural, or step-connected; many readers need the picture
before the symbols. A figure has to earn its space by revealing structure the prose can't show as
cheaply. Skip decorative ones.

**Static SVG is the default.** Self-contained, inline in the HTML. Compute real coordinates (a short
script that emits the SVG keeps it accurate and consistent with the running example); never eyeball
geometry and never hit a CDN/remote image. Style to the palette. Wrap in `<figure>` + `<figcaption>`
and make it responsive (`width:100%; height:auto`).

**Never hand-align ASCII-art diagrams in `<pre>` for spatial or sequence flows** (party-to-party message
exchanges, data-flow layouts, anything with columns that must line up). Space-counted column alignment
silently breaks across fonts (Iosevka missing, fallback metrics differ) and it forces raw `^`/`_`
notation. Use an inline SVG sequence/flow diagram instead. Left-aligned pseudocode in `<pre>` is fine;
spatial ASCII art is not.

**The typed-wire flowchart** is the gold-standard "how the pieces connect" figure for any
multi-step construction (algorithms, protocols, derivations). Model it on the best reference:

- One box per intermediate value, each carrying a fixed role color (see the color map below).
- Orthogonal connector wires between boxes, each labeled with the data type flowing (`int`,
  `bytes`, a point, etc.).
- Small inset plots inside boxes where a value lives on a curve/graph.
- A **Key / legend** box defining every symbol used.

**Live widgets: visualization-linked ONLY.** A live widget is worth it exactly when watching
something *change* is the insight: the reader adjusts a control (slider, number input) and a rendered
figure updates in real time (a line's slope, a point moving along a curve, a distribution reshaping).
Do NOT build form-fill "compute this and dump the output" tools; a static worked example does that
job better. If a widget wouldn't make a figure move, it shouldn't exist. All JS inlined, no
dependencies, no network.

## Step 6 - Finalize

- Save to the current working directory as `./<topic-slug>.html` (kebab-case slug of the subject).
  Mention the full path when done. If the cwd is clearly not the right home, name a better path or
  ask.
- Run the correctness guard from Step 3 if you haven't: recompute the running example's numbers.
- Open it for the user: `open <file>` (macOS) or `xdg-open <file>` (Linux).

## Output contract (styling and rendering)

The document is **fully self-contained**: all CSS, JS, and SVG inlined, no CDN, no network fetches.
It renders offline and prints cleanly.

The document **must** begin with `<meta charset="utf-8" />` as the first line of the head (before the
`<title>`). Without it, a browser opening the file over `file://` guesses the encoding and decodes the
UTF-8 bytes as Latin-1, mangling all the Unicode math (superscripts, subscripts, symbols) into mojibake
(e.g. `2⁰..2¹⁰` renders as `2â °..2Â¹â °`). This is non-negotiable for any doc using Unicode math.

### Palette and type

Catppuccin Mocha, dark, mauve as the primary accent, Iosevka Nerd Font. Embed this token block as
`:root` and draw every color from it:

```css
:root {
  /* Catppuccin Mocha */
  --crust:#11111b; --mantle:#181825; --base:#1e1e2e;
  --surface0:#313244; --surface1:#45475a; --surface2:#585b70;
  --overlay0:#6c7086; --overlay1:#7f849c; --overlay2:#9399b2;
  --subtext0:#a6adc8; --subtext1:#bac2de; --text:#cdd6f4;
  --rosewater:#f5e0dc; --flamingo:#f2cdcd; --pink:#f5c2e7; --mauve:#cba6f7;
  --red:#f38ba8; --maroon:#eba0ac; --peach:#fab387; --yellow:#f9e2af;
  --green:#a6e3a1; --teal:#94e2d5; --sky:#89dceb; --sapphire:#74c7ec;
  --blue:#89b4fa; --lavender:#b4befe;
  /* roles */
  --bg:var(--base); --panel:var(--mantle); --ink:var(--text); --muted:var(--subtext0);
  --accent:var(--mauve); --rule:var(--surface0); --hl:rgba(203,166,247,.14);
  --font:"Iosevka Nerd Font","IosevkaTerm Nerd Font","Iosevka NF","Iosevka",
         ui-monospace,"Cascadia Code",Menlo,monospace;
}
body { font-family:var(--font); background:var(--bg); color:var(--ink); }
a { color:var(--mauve); }
```

Iosevka is monospace, so the whole document reads mono; that's intended. It must be installed
locally to render; the stack falls back to other monospace fonts otherwise. Mauve for
headings/links/emphasis and math accents. Use the other accents sparingly and by role.

### Layout and readability

Constrain running prose to a comfortable measure: a centered column of roughly **70-80ch** (mono runs
wide, so cap it) via a `--measure` token and `max-width`. Let figures, code panels, and wide tables
break full-bleed beyond that column. Lay out sibling groups with flex/grid `gap` rather than
per-element margins that collapse or double. Use `font-variant-numeric:tabular-nums` wherever the
running example's digits line up in columns, so they stay aligned. Watch selector specificity so
component rules do not silently cancel each other's spacing.

### Functional color (never decorative)

Color carries meaning. Assign a role to each accent and keep it consistent across prose, code, and
diagrams, so the same idea is the same color everywhere. Suggested mapping (adapt per subject, then
hold it fixed):

| Role                         | Color              |
|------------------------------|--------------------|
| Secret / private / danger    | `--red`            |
| Public / safe-to-share       | `--green` / `--teal` |
| Primary concept / challenge  | `--mauve`          |
| Result / output              | `--pink`           |
| Data flow / intermediate     | `--blue` / `--lavender` |

### Callouts

Four types, each a tinted rounded box with a bold colored lead word. May nest code/math/figures.

- **Tip** - green tint, green lead.
- **Note** - yellow tint, yellow lead.
- **Caution** - peach tint, peach lead.
- **Warning** - red tint, red lead.

### Code and long values

Dark panel (`--mantle`/`--crust`), `--rule` border, a language label, functional syntax colors from
the palette. Standalone hex/long values get their own boxed treatment.

**Never let code or long values silently truncate.** Long lines and giant hex strings go in an
`overflow-x:auto` scroll container, or wrap deliberately. (This is the one clear flaw in the
reference material; design around it.)

### Math

Default to **Unicode + styled HTML** for inline expressions, sub/superscripts, and single-line
equations, in a `.math` span in the accent color. Render sub/superscripts as real `<sub>`/`<sup>`
tags or Unicode (`x₁`, `k⁻¹`), never literal LaTeX underscores (`u_A` reads as a bug; write
`u<sub>A</sub>`). This holds inside code/pseudocode panels and SVG `<text>` too, not only prose. Unicode
subscripts are incomplete (there is no subscript `b`, `c`, `d`, ...), so use real `<sub>` tags in HTML or
`baseline-shift="sub"` tspans in SVG for letter subscripts; reserve Unicode subscripts for the ones that
exist. On multi-line code/equation blocks set `white-space:pre-wrap` and keep each line short so it
doesn't wrap mid-content.

Reach for **KaTeX only when Unicode gets genuinely cramped** (multi-level fractions, matrices, large
operators with limits, aligned multi-line derivations). Then vendor it locally: inline it, or drop a
sibling `assets/` dir and reference it with relative paths. Never load KaTeX/MathJax from a CDN, it
breaks the self-contained/offline guarantee.

### Build cleanly

Respect `prefers-reduced-motion`: any animation or live widget must degrade to a static, readable
state under it. Give every interactive control (slider, input, link) a visible `:focus-visible` state.
Close every non-void tag and quote every attribute. These cost nothing and protect the offline,
printable, keyboard-usable guarantees.

### Voice

Conversational but precise. Intuition first, then the formal statement. Analogies only when they
genuinely clarify. Cite as you claim. No em dashes.

## Notes

- One subject per document. Resist scope creep; a focused doc that teaches one thing well beats a
  survey that teaches nothing deeply.
- The running example is the spine, not garnish. If a section can't advance it, question whether the
  section belongs.
- Prefer showing the reader a number they can check over telling them to trust you.
