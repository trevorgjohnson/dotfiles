---
name: pr-annotate
description: >-
  How to leave review feedback on someone else's PR in Trevor's voice: findings as inline
  annotations anchored to the diff, one or two plain sentences each, `suggestion` blocks for
  mechanical fixes, short warm review body. Load this whenever a review's findings are about to
  be posted to GitHub (after `/review`, `/code-review`, or "leave comments on PR N"), before
  writing any comment bodies.
triggers:
  - /pr-annotate
---

# PR annotations

Findings go in **inline comments anchored to the diff line they are about**, never in a long review body and never as a markdown report in a single comment. One comment per finding. The reader is looking at the hunk, so the comment only has to say the thing.

## Voice

Calibrated from Trevor's real review comments (`prometheumlabs/cows#1145` is a good corpus).

- **One or two sentences. Hard ceiling.** Almost every real comment is a single sentence.
- **Plain natural language.** No headers, no bold labels, no `Issue:` / `Impact:` / `Severity:` scaffolding, no bullet lists inside a comment.
- **Hedged and collaborative.** "we should probably", "this could likely", "seems like", "doesn't look like", "perhaps we could", "wonder if". Say "we", not "you".
- **Sentence case, lowercase openers are fine.** "same here", "this doesn't seem like it's in the right place", "seems to be unused now".
- Backtick every identifier, path, version, and flag.
- No em dashes. No emoji in findings (they belong in replies and approvals).
- State the consequence only when it is not obvious from the line. One clause, not a paragraph.
- Prefix genuinely optional polish with `nit:`.

Real examples to match:

> This should probably be bumped to `^0.8.35` like the rest of the contracts

> seems to be unused now

> We can likely drop this file too since it's just a mock

> This is a pretty generic name, perhaps we could rename to be more specific? Something like `setUpHHTask` or something?

> `das` and `amount` are always defined so we can drop `| undefined` and the associated `if !(das)...` guards too. probably need to re-review which other inputs are always defined or not too

> We should probably simplify this to just forward to a single address for the time being. No need for a for loop or multiple receivers/values

Anti-example, do not write this:

> **Base image drift (blocking).** `Dockerfile:188` pins `24.18.0` while stages `:2,18,84,105,165` pin `24.18.1`. **Impact:** the image ships an older base with unpatched CVEs and Renovate must issue a second bump. **Fix:** align the digest.

## Shape

- **`suggestion` blocks for anything mechanical** (a version bump, a dropped type, an added key, a doc line). Show the fix instead of describing it. The block must contain the full replacement for exactly the commented line range.
- **Repeats get "same here" or "same thing goes for each of these"**, not a restated finding. Link the original with its `#discussion_r...` URL when it is in another file.
- **A finding about an untouched file** still gets an inline comment: anchor it to the closest related line in the diff and name the other file in the body.
- **Forward-looking ideas are fine** if marked as such: "in the future, we could also add ... but that can be added later."
- **Bigger design pushback** is the one place to spend more room: a short paragraph plus a code block sketching the alternative. Still no headers.
- **Review body is one or two warm sentences**, no summary of the findings. "Nice work! I've just left some comments/suggestions but it looks really good so far!" / "LGTM! Great work @user 🎉 I've just got 3 small comments but I approve anyways". Approve with open nits when nothing is load-bearing.

## Mechanics

Post as one review, not N standalone comments:

```bash
gh api repos/{owner}/{repo}/pulls/{n}/reviews --method POST --input review.json
```

`review.json`: `{commit_id, body, comments: [{path, line, side: "RIGHT", body}]}`, plus `start_line` for a range. Build it with a small python heredoc so the `suggestion` fences and newlines survive.

- `commit_id` must be the current head (`gh pr view {n} --json headRefOid`). Re-check that head has not moved since the diff was gathered; if it has, re-verify the findings before posting.
- Anchor lines are new-file line numbers and must fall inside a diff hunk. Get them from the file at head (`gh api ...contents/{path}?ref={sha}` piped to `base64 -d | grep -n`), not from a local checkout.
- Omit `event` to leave the review **pending** (author-only) and let Trevor submit it. Only pass `event: COMMENT`/`APPROVE` when he says to send it.
- Verify anchors afterward: `gh api .../reviews/{id}/comments --jq '.[] | "\(.path) \(.diff_hunk|split("\n")|.[-1])"'`. Pending comments report `line: null`, so the last line of `diff_hunk` is the real check that a comment landed where intended.

Related: the mirror rule for annotating **your own** PR is in memory as `feedback-pr-annotations-over-body` (same inline-over-body preference, slightly longer bodies since they explain a fix rather than request one).

## Posting under Trevor's account

If there's no separate bot/LLM GitHub token available, the review posts under Trevor's own authenticated `gh` account. In that case prefix every comment body (and the review body) with `🤖 ` so it's unmistakably LLM-authored, not Trevor reviewing by hand. This overrides the "no emoji in findings" voice rule for the prefix specifically — the rest of the sentence still follows normal voice. Skip the prefix entirely if posting through an actual bot/app identity.
