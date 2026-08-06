---
name: deliverable-style
description: >-
  The single source of truth for how Trevor's standalone HTML deliverables look and read:
  Catppuccin Mocha, mauve accent, Iosevka, self-contained, code-forward, rendered math, static SVG
  figures. Load this before writing any `.html` artifact (explainers, flow docs, reference pages,
  one-off pages) and before choosing colors for a chart inside one. Other skills that emit HTML
  point here instead of carrying their own palette.
---

# Deliverable style

House style for standalone HTML deliverables. Governs **how it looks** and **how it reads**, not
what sections it has. Document structure belongs to the skill that invoked this one (`explain`,
`document`) or to your judgment for a one-off.

The point of this file is a fixed substrate with free expression on top. Same paint, different
painting every time. Do not turn every deliverable into the same page.

## Locked

Never varies, never asked about:

- The 26 Mocha hexes below. Draw every color from the tokens, never a raw hex in a rule.
- **Mauve `#cba6f7` is the primary accent.** Headings, links, emphasis, math. Nothing else takes
  that job.
- Dark. There is no light mode, no Latte twin, no `@media print` block.
- The Iosevka stack. Everything reads mono, including body prose. That is intended, not an
  oversight.
- **Fully self-contained.** All CSS, JS, SVG inlined. No CDN, no webfont fetch, no network at
  runtime. It has to work offline off `file://`.
- `<meta charset="utf-8" />` as the **first line of `<head>`**, before `<title>`. Without it a
  browser opening `file://` decodes UTF-8 as Latin-1 and every math glyph turns to mojibake.

```css
:root{
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
body{font-family:var(--font);background:var(--bg);color:var(--ink)}
a{color:var(--mauve)}
```

## Free

Curate these toward the subject every time:

- Layout and column structure. Which components appear at all.
- Which accent means what (see functional color).
- Figure style, density, length. A small topic gets a short page.
- Whether there are figures, widgets, or tables at all.

## Reads like

Trevor is visual and a programmer. Both halves matter.

- **A mechanism never gets prose alone when code would say it in eight lines.** Documenting a real
  system? Real source, real names, real signatures, from the code. Explaining a language-agnostic
  idea? Tight pseudocode. Describing a shape? A struct plus a diagram.
- **Math gets rendered, not described.** See below.
- **Reach for a figure whenever the thing is spatial, structural, or step-connected.** The picture
  usually has to land before the symbols do.

## Layout

Running prose in a centered column of roughly **70-80ch** via a `--measure` token. Mono runs wide,
so cap it. Figures, code panels, and wide tables break full-bleed past it.

Space sibling groups with flex/grid `gap`, not per-element margins that collapse or double. Set
`font-variant-numeric:tabular-nums` anywhere digits align in a column. Watch specificity so
component rules do not silently cancel each other's spacing.

Wide content lives in its own `overflow-x:auto` container. The page body never scrolls sideways,
and **code and long hex values never silently truncate.**

## Functional color

Color carries meaning, never decoration. Pick a role map for the subject, then hold it fixed across
prose, code, figures, and pills so the same idea is the same color everywhere. A reasonable
starting map, adapt per topic:

| Role                        | Color                   |
|-----------------------------|-------------------------|
| Secret / private / danger   | `--red`                 |
| Public / safe to share      | `--green` / `--teal`    |
| Primary concept             | `--mauve`               |
| Result / output             | `--pink`                |
| Data flow / intermediate    | `--blue` / `--lavender` |

Keep mauve as the document accent. Do not let a state ramp fight it.

**Callouts:** tinted rounded box, bold colored lead word, may nest code and figures. Tip green,
Note yellow, Caution peach, Warning red.

## Code

Panel on `--mantle` or `--crust`, `--rule` border, language label.

Highlighting is **layered**:

1. **Muted syntax base.** Keywords, strings, comments, types get low-contrast palette colors
   (`--overlay1`, `--subtext0` range). Deliberately quiet.
2. **Semantic overlay on top.** The tokens the prose is actually discussing take their role color
   from the map above, so the secret is red in the code, red in the figure, and red in the
   sentence.

The base must stay quiet enough that the overlay reads over it. If a panel looks busy, mute the
base further, do not drop the overlay.

Multi-line blocks: `white-space:pre-wrap`, and keep lines short (~68 chars) so they do not wrap
mid-content. Trailing comments go on their own line rather than being space-padded into a column.

## Math

**Unicode plus styled HTML is the default** for inline expressions, simple sub/superscripts, and
single-line equations. Wrap in a `.math` span in the accent color.

Render sub/superscripts as real `<sub>`/`<sup>` or Unicode (`x₁`, `k⁻¹`). **Never literal LaTeX
source in output** (`u_A` reads as a bug; write `u<sub>A</sub>`). This holds inside code panels and
SVG `<text>` too. Unicode subscripts are an incomplete set, so use real `<sub>` in HTML and
`baseline-shift="sub"` tspans in SVG for letter subscripts.

**Escalate to native MathML** when Unicode gets cramped: multi-level fractions, matrices, large
operators with limits, aligned derivations. Every current browser renders MathML Core natively, so
this costs zero bytes and keeps the self-contained guarantee.

**Never KaTeX or MathJax.** Unicode and MathML cover the range, and a CDN breaks offline.

## Figures

**Static inline SVG is the default.** Compute real coordinates (emit them from a short script;
never eyeball geometry), style from the tokens, wrap in `<figure>` + `<figcaption>`, make it
responsive (`width:100%;height:auto`).

**Never hand-align ASCII art in `<pre>` for anything spatial.** Column alignment silently breaks
when Iosevka is missing and fallback metrics differ. Left-aligned pseudocode in `<pre>` is fine;
spatial diagrams are not. Use SVG.

**No mermaid.** It needs a runtime that offline `file://` will not have.

High-value figure types: pipeline/service map, numbered sequence with the responsible layer tagged,
status/state machine, message and field anatomy, and the **typed-wire flowchart** (one box per
intermediate value in its role color, orthogonal wires labeled with the type flowing, a key box
defining every symbol) for multi-step constructions.

**Interactive only when motion is the insight.** A control earns its place when dragging it makes a
figure move and that movement is the lesson. Never build form-fill "enter values, click Compute"
tools; a worked example does that better. All JS inlined. Honor `prefers-reduced-motion` with a
readable static state, and give every control a visible `:focus-visible`.

## Charts

Load the `dataviz` skill for **form**: chart type, axes, legends, tooltips, contrast checks, stat
tiles. Override its palette with **these colors**, in this order:

```
series 1  --mauve     #cba6f7
series 2  --teal      #94e2d5
series 3  --peach     #fab387
series 4  --blue      #89b4fa
series 5  --pink      #f5c2e7
series 6  --yellow    #f9e2af
grid/axis --surface1  #45475a      labels --subtext0  #a6adc8
```

A chart should look like part of the document, not a foreign object pasted into it.

## Publishing

These are normally local files. Save as `./<topic-slug>.html`, state the full path, and `open` it.
Reopen after any regeneration; the browser will not pick up a file change on its own.

If it goes out as a published Artifact instead: Iosevka is not installed for the viewer and the CSP
blocks font CDNs, so it falls back down the stack to their system mono. That is acceptable. Do not
try to inline the font and do not swap to a webfont. Everything else in this file carries over
unchanged.
