# Lesson Visual Style (default)

User's standing aesthetic preference for all lesson and reference HTML:
**Catppuccin Mocha** palette, **mauve** as the primary accent, **Iosevka Nerd Font**
as the typeface. Dark theme. Keep the Tufte sensibility (generous space, clear
hierarchy, restrained color) — just rendered in this palette and font.

Embed this as the `:root` token block in every lesson/reference HTML, keep CSS
self-contained (no network/CDN), and draw all colors from these tokens.

```css
:root {
  /* Catppuccin Mocha */
  --crust:#11111b; --mantle:#181825; --base:#1e1e2e;
  --surface0:#313244; --surface1:#45475a; --surface2:#585b70;
  --overlay0:#6c7086; --overlay1:#7f849c; --overlay2:#9399b2;
  --subtext0:#a6adc8; --subtext1:#bac2de; --text:#cdd6f4;
  --mauve:#cba6f7; --lavender:#b4befe; --pink:#f5c2e7; --red:#f38ba8;
  --peach:#fab387; --yellow:#f9e2af; --green:#a6e3a1; --teal:#94e2d5; --blue:#89b4fa;
  /* roles */
  --bg:var(--base); --panel:var(--mantle); --ink:var(--text); --muted:var(--subtext0);
  --accent:var(--mauve); --rule:var(--surface0); --hl:rgba(203,166,247,.14);
  --font:"Iosevka Nerd Font","IosevkaTerm Nerd Font","Iosevka NF","Iosevka",
         ui-monospace,"Cascadia Code",Menlo,monospace;
}
body { font-family:var(--font); background:var(--bg); color:var(--ink); }
a { color:var(--mauve); }
/* code/math blocks: --panel or --surface0 bg, --rule border, --mauve for math/accent.
   ALWAYS set white-space:pre-wrap on multi-line code/equation blocks — without it
   newlines collapse and lines run together. With pre-wrap, also keep each line short
   (≈ ≤ 68 monospace chars) so it doesn't wrap mid-content; put trailing comments on
   their own line instead of padding with many spaces. */
```

Accent usage: mauve for headings/links/emphasis and "math" spans; use lavender, blue,
green, peach sparingly for secondary distinctions (e.g. annotations, "good vs bad").
Highlight (`--hl`) is a translucent mauve wash for call-outs and the cross-term marks.

Iosevka is monospace, so the whole document reads mono — that's intended. It must be
installed locally to render; the stack falls back to other monospace fonts otherwise.

For print (`@media print`) it's fine to keep the dark theme or drop to a light fallback;
default is to keep dark since these are read on screen.

## Retrieval-practice (recall) widget

When a lesson includes recall prompts, make each answer **separately** click-to-reveal so
the learner actually attempts retrieval before checking. Pattern: a `.recall` container,
then one `<details class="qa">` per item where the `<summary>` is the question and a
`.a` paragraph (own line, distinct accent — e.g. green left border + "A" badge) is the
answer. Never put the answer inline after the question (it spoils the retrieval and reads
cramped). In `@media print`, force `details > * { display:block !important; }` so answers
appear on paper.

## Math rendering

Default to **Unicode + styled HTML** (a `.math` span in the accent color) for inline
expressions, simple sub/superscripts, and single-line equations. Keep lessons fully
self-contained — no math CDN.

Render subscripts/superscripts as real `<sub>`/`<sup>` tags (or Unicode like `x₁`, `m₀`),
**never as literal LaTeX-style underscores** — `u_A` shows the underscore and reads as a
bug. Write `u<sub>A</sub>`. Apply this inside code/`.block` elements too (HTML is parsed
there). In SVG figures, use `<tspan baseline-shift="sub" font-size="0.72em">`. Keep this
consistent within and across a workspace's lessons.

Use **KaTeX vendored locally** (assets checked into the workspace under
`reference/vendor/katex/`, loaded with relative paths so it renders offline) **only when
necessary** — i.e. when Unicode would be cramped or ambiguous: multi-level fractions,
matrices/vectors, large operators with limits (Σ/∏ with sub+superscripts), aligned
multi-line derivations, cases, ideal-functionality boxes. Vendor on first real need, not
preemptively. Never load KaTeX/MathJax from a CDN (breaks offline/self-contained).

## Diagrams and figures

Visualizations make abstract/structural ideas land — favor them, and add them proactively
for anything spatial or structural (curves, graphs, geometry, state machines, data flows,
matrices, protocol message-passing). Many learners need the picture before the symbols.

- Use **self-contained SVG** — either inline in the HTML or a local `.svg` under
  `reference/figures/` referenced with a relative `<img src>`. Never a CDN/remote image.
- **Compute real coordinates** rather than eyeballing them. A short script (e.g. Python)
  that emits the SVG keeps diagrams accurate and regenerable; numbers must match the
  running example.
- Style to the palette (Catppuccin Mocha, mauve accent) so figures match the lessons; wrap
  in `<figure>` + `<figcaption>` and make them responsive (`width:100%; height:auto`).
- A good figure earns its space — skip decorative ones; each should reveal structure the
  prose can't show as cheaply.
