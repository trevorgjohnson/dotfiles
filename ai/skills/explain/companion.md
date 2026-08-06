# The runnable companion

Load this only when the user accepts the companion offer from Step 7.

A runnable file that implements the subject end to end, heavily documented, that the reader can
execute and watch produce the article's numbers.

Reference for the form: https://gist.github.com/tarassh/38553c0d51787fff0ee9b506facf07ae (MtA over
oblivious transfer, Python). What the companion must do:

- **Module docstring as the map.** The overview, the correctness and security properties, and the
  mathematical foundation as numbered steps, before a line of code.
- **One named method per step, in wire order** (`step1_send_ot`, `step2_receive_ot`, ...) so the code
  reads as the same sequence as the article.
- **Docstrings carry the why and the math**, not just args and returns. Include the case analysis
  that proves the invariant holds.
- **Parties are objects, not a script.** Each side holds only its own secrets, so what each party
  knows is legible from the type.
- **A demo that narrates.** A `main` runs the article's running example and prints every intermediate
  value, using the same symbols the article uses.
- **Ends by asserting the invariant** and printing pass/fail. The reader watches the claim get
  verified rather than being told to trust it.
- **Same numbers as the article.** The printed intermediates must match the worked example. If they
  disagree, one of the two is wrong; fix it before shipping either.

Language follows the subject's canonical one, Python otherwise. Prefer a single file on the standard
library. Reach for a third-party library only when hand-rolling the primitive would bury the lesson
(big-number crypto, linear algebra, plotting); then keep it to one or two, state the exact install
command in the module docstring, and confirm it runs in a clean environment.

Save it beside the document as `./<topic-slug>.<ext>`, run it once to confirm it executes and the
assertion passes, and paste the real output. Never present untested code as runnable.
