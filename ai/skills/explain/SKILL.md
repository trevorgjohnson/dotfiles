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
file on disk, opened in the browser. The bar is the great long-form explainer: motivate before you
formalize, build bottom-up, anchor in real numbers, and explain not just what a thing does but why
it was built that way.

**This is a bar, not a template.** Only the correctness guard is mandatory. Everything else is a
technique to reach for when the subject calls for it. Pick the shape that fits this subject; a
section that does not serve it does not belong in the document. Do not force a device in to satisfy
a checklist.

## The bar

- **Motivation before mechanism.** Open on a concrete scenario or a real gap. Earn the math before
  you show it. If the reader arrives skeptical or intimidated, name that in the hook and answer it
  ("SIMD has a reputation for being complex ... I think that's wrong").
- **Bottom-up sequencing.** Each concept is a prerequisite for the next. If section 4 needs an idea,
  section 3 taught it.
- **Simplest version first, then earn every complexity.** Lead with the stripped-down or even
  outright broken model because it is easier to hold, then add each complication by naming the exact
  problem that forces it. Restate the one central artifact whole after every upgrade with the change
  marked; never leave the reader holding a diff. Two shapes this takes. The naive version presented
  in full, then broken at a named step ("the issue lies in step 5"), then fixed. Or the hardest
  prerequisite hoisted clean out of the sequence, replaced by a descriptive placeholder and an
  explicit IOU ("assume this special multiplication has no inverse; trust me, it exists, I'll cover
  it in a moment"), the whole structure taught on the easy substrate, then the real primitive
  substituted back at the end. Track that IOU and visibly discharge it.
- **Derive, don't reveal.** Name the deficiency, then state the property a solution would need, and
  only then produce the tool and its real name. "I need to commit to k without being able to change
  my mind afterwards" comes before "use a hash function", which comes before "this is called a
  Fiat-Shamir transformation". A mechanism introduced this way feels derived instead of conjured.
- **Why, not just what.** What breaks if you do it the obvious way, what attack or failure the
  design prevents. This is what stops cargo-cult understanding.
- **Name the transferable shape.** If the subject has a reusable pattern under the instance, name it
  and hand it over. The reader should leave able to recognize the situation in their own code, not
  just able to follow this example.
- **Hand off at every section boundary.** Say what was just earned and what is still missing before
  reaching for the next tool: "now that we have RSA, we can build oblivious transfer"; "but surely we
  don't expect ourselves to build all of this at gate level, right?"
- **Intuition first, rigor deployed selectively.** Analogies only when they genuinely clarify.
- **Canonical notation arrives last, as compression.** Teach with descriptive names, then collapse to
  the field's real symbols near the end ("the challenge hash is called e, the public nonce point is
  called R") and land on the exact form the reader will meet in the wild. Notation earned this way is
  a summary of something already understood rather than vocabulary to memorize up front.
- **Close small loops in place.** A parenthetical beats a derail: "(there are MPC protocols for more
  than two parties, but we'll cover two-party here.)"

## Step 1 - Scope

Parse the subject and any audience/depth notes. Proceed directly to building if the goal is clear.
Ask first ONLY when audience (where the bottom-up sequence starts), the one idea they must walk away
with, or depth (working intuition vs implementable rigor) is genuinely ambiguous. A sentence of
clarification is usually enough; if intent is obvious, skip this step.

## Step 2 - Ground (adaptive sourcing)

Choose the sourcing mode from the subject, not by habit:

- **Technical / factual** (protocols, algorithms, specs, APIs, math, anything with exact values or a
  canonical definition): research FIRST. Pull the primary sources (specs, papers, RFCs, official
  docs) before writing. Never trust parametric knowledge for exact constants, algorithm steps, or
  security claims; these are the hallucination-prone parts.
- **Conceptual / well-trodden** (general ideas, intuitions, history): parametric knowledge is fine.

When you research, cite inline at the point each non-trivial claim is made (a real link), prefer the
highest-trust source (spec > paper > official docs > reputable secondary > forum), close with a
**References** list, and point the reader at one primary source to go deeper.

## Step 3 - Anchor in real numbers

Pick concrete, visualizable scenarios with **real, computed values**. Named actors doing a tangible
thing beat abstract symbols. Small hand-checkable numbers where the topic allows (the reference
explainers work in `mod 23` or `mod 97` precisely so the reader can verify each step by hand), and
say plainly when those numbers are a toy and why: "too small for this system to be secure, and normal
multiplication isn't a good choice because you can just use division to work out the private key."

How the example threads depends on the subject:

- **Concepts that compose into one object**: carry a single example the whole way, accreting on prior
  state rather than resetting. This is usually the stronger choice.
- **A stack of independent primitives**: let each section have its own small example, then pay it all
  off by running the assembled thing end to end with real values. Forcing one continuous example
  across prime generation, RSA, oblivious transfer, and garbled circuits would only contrive it.

**Correctness guard (required).** Every number in the document is either computed or cited. Do the
arithmetic in a scratch script rather than eyeballing it, and if a code listing shows output, that
output came from actually running it. When the subject has published test vectors, use those as the
example values so the reader can cross-check against the spec and any other implementation. Invented output is the same defect as an invented intermediate
value. Quantified stakes in the hook are real measurements from a named source, ideally from an
ordinary domain rather than a specialist one (a 5x speedup in a terminal emulator lands harder than
one in an HPC kernel). If a value cannot be verified, do not present it as fact.

## Step 4 - The arc

The beats below are what most explainers need, in roughly this order. Include the ones this subject
earns; drop the rest.

1. **Title + one-line framing** - what this teaches and who it's for.
2. **Hook** - the concrete scenario, the gap, or the reader's own skepticism.
3. **What you'll understand + prerequisites** - the floor of the bottom-up sequence.
4. **The concept sequence** - the body, per the bar above.
5. **Objections, answered where they land.** Distinct from misconceptions: an objection is a reason
   the reader disengages, and it has to be met at the moment it occurs to them, not filed at the end.
   A strong one earns its own section ("why can't the compiler do this?").
6. **Misconceptions / gotchas** - the wrong mental models a reader tends to form, corrected.
7. **Recap + go deeper** - a tight synthesis, the single best source to read next, References.

Order can serve two readers at once instead of compromising between them. The Schnorr reference puts
the full working implementation first, for whoever just needs to ship it, and the theory last as an
explicitly optional payoff ("you don't need to know how Schnorr signatures work to be able to add
them to your code, but it's cool to see how they do"), with the closing derivation landing on the
exact equation the implementation opened with. Reach for that when the subject has both a
practitioner and a curious reader.

Two beats worth reaching for when they fit, and only then: **putting it all together**, where the
whole construction runs end to end, and **when this applies and when it doesn't**, with real
thresholds rather than hedges ("millions of bytes, the payoff is huge; dozens, it isn't worth it").
The second is valuable for a technique the reader might adopt and pointless for a primitive they
just want to understand.

Length follows the concept, not a target. Do not pad. One tightly-scoped subject per document; if
it's genuinely too big, say so and propose linked docs rather than shipping a bloated one.

## Step 5 - Visuals, code, interactivity

The figure and code contract lives in the `deliverable-style` skill: static SVG default, the
typed-wire flowchart for multi-step constructions, the no-spatial-ASCII-art rule, code panel
styling, and when a live widget earns its place. Follow it.

Explain-specific: favor visuals for anything spatial, structural, or step-connected, since many
readers need the picture before the symbols. A figure earns its space by revealing structure the
prose can't show as cheaply, and it should advance the example rather than sit beside it. When a
script emits SVG, it also keeps the coordinates consistent with the real numbers.

Two moves that fit some subjects well. When the whole artifact is small and visible (a dozen lines
of code, a wire sequence, one formula), showing it whole up front and then decomposing it gives the
reader a frame to hang the parts on, which is worth the one forward reference. And when the point of
the subject is that you can build it, the listings belong inline and incremental, growing across the
document, with working code carrying the rigor that a proof would otherwise. Neither is a default.

## Step 6 - Finalize

- Save to the current working directory as `./<topic-slug>.html`. Mention the full path when done. If
  the cwd is clearly not the right home, name a better path or ask.
- Run the correctness guard if you haven't.
- Open it: `open <file>` (macOS) or `xdg-open <file>` (Linux).

## Step 7 - Optional: the runnable companion

When the subject is implementable and a reader would plausibly want to execute it, offer a runnable
companion in a single line after the document is open. Skip the offer when it wouldn't add anything;
a single primitive explained well often needs no separate program. Build it only if the user says
yes, and read `companion.md` in this skill directory for the spec.

## Output contract (styling and rendering)

**Load the `deliverable-style` skill and follow it.** It is the single source of truth for the
palette and token block, type, layout and measure, functional color, callouts, code panels, math
(Unicode default, MathML escalation, never KaTeX), figures, charts, and the self-contained
guarantee. Do not restate or fork any of it here.

### Voice

Conversational but precise. Intuition first, then the formal statement. Cite as you claim. For
anything interactive, first person with a direct counterparty ("I send you the public nonce, you send
back a challenge") puts the reader inside the protocol and beats third-person Alice and Bob.

## Reference explainers

The bar above is distilled from these. Worth a look when you want a model for a specific device.

- `learnmeabitcoin.com/technical/cryptography/elliptic-curve/schnorr/` - placeholder-and-IOU,
  derive-don't-reveal, notation-last, implementation-first ordering, spec test vectors.
- `zellic.io/blog/mpc-from-scratch/` - naive-then-broken-then-fixed, gap-naming handoffs, per-primitive
  examples paying off in one end-to-end run, working code carrying the rigor.
- `mitchellh.com/writing/everyone-should-know-simd` - skeptic hook, whole-then-decomposed, the named
  transferable shape, scope thresholds.
