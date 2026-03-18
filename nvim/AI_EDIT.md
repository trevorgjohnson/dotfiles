# AI Edit Plugin Notes

## Goal

Small private Neovim plugin for async AI-assisted edits with explicit review/apply semantics.

Core workflow:

1. Visually select a range.
2. Send the selection plus nearby context and a prompt to an AI CLI in the background.
3. Keep editing while the job runs.
4. Review the result later from a dedicated review buffer or quickfix queue.
5. Explicitly apply or dismiss the change.
6. Refuse automatic apply if the target range changed.

## Current MVP

Implemented under:

- `lua/user/ai_edit/init.lua`
- `lua/user/ai_edit/job.lua`
- `lua/user/ai_edit/review.lua`

Wired from:

- `init.lua`

### Setup

Current setup is minimal:

```lua
require("user.ai_edit").setup({
  cli = { "codex", "exec", "--skip-git-repo-check" },
  context_lines = 10,
})
```

The plugin assumes:

- the CLI accepts a single prompt as the final argv item
- the proposed replacement is returned on stdout
- the replacement should apply only to the selected range

## Commands / Keymaps

### Generate

- Visual: `<leader>ae`
- Command: `:'<,'>AIEdit`

Captures:

- selected text
- `context_lines` before and after
- file path
- range metadata

### Review

- Normal: `<leader>ar`
- Command: `:AIEditReview`

Opens the latest open job for the current file in a scratch review buffer.

### Quickfix Queue

- Normal: `<leader>aq`
- Command: `:AIEditQf`

Rebuilds quickfix from open review jobs only. Quickfix now points directly at review buffers, so `:cnext` / `:cprev` moves through the review queue.

### Apply

- Normal: `<leader>aa`
- Command: `:AIEditApply`

Applies only if the current buffer text at the original saved range still exactly matches the captured original text.

On success:

- status becomes `applied`
- Neovim jumps to the edited code location
- `<C-o>` should return to the prior review location

On mismatch:

- status becomes `stale`
- automatic apply is refused

### Diff

- Normal: `<leader>ad`
- Command: `:AIEditDiff`

Opens a new tabpage containing a diff between:

- current text at the saved range
- proposed AI replacement

Useful tab navigation:

- `gt` next tab
- `gT` previous tab
- `:tabclose` close diff tab

### Dismiss

- Normal: `<leader>ax`
- Command: `:AIEditDismiss`

Marks the current job as `dismissed`, removes it from future quickfix rebuilds, and closes the review buffer if invoked there.

## Job Storage

State root:

- `stdpath("state")/ai-edit/jobs/<job-id>/`

Artifacts per job:

- `request.json`
- `prompt.txt`
- `original.txt`
- `stdout.txt`
- `stderr.txt`
- `result.txt` on success
- `status.json`

## Status Model

Current statuses:

- `running`
- `ready`
- `stale`
- `applied`
- `dismissed`
- `failed`

Quickfix includes only open review work:

- `ready`
- `stale`

## Important Design Decisions

- `vim.system()` is used for async execution.
- No tmux runner in v1.
- No patch parsing in v1.
- No extmark-based relocation in v1.
- Apply is strict exact-match only.
- Manual merge is handled through diff, not automatic merge logic.
- Review/apply are explicit; no blind buffer replacement.

## Known Behavior / Notes

- The failure notification path is still imperfect with the Codex CLI. Job state is correct and stderr/status artifacts are saved, but Neovim notify output on failures may still be odd depending on CLI behavior.
- Codex appears to duplicate useful output across streams in some cases. The review buffer now hides stderr for successful jobs.
- Review buffers are persistent hidden scratch buffers so quickfix navigation can revisit them safely.

## Recommended Next Steps

### First

Do one more normal-session validation pass:

- create multiple jobs
- review from quickfix
- apply one
- dismiss one
- force one stale
- use diff for manual inspection

### Near-Term Refactor

Rename the module namespace from `ai_edit` to a more general `ai` while the surface area is still small.

Current module paths:

- `lua/user/ai_edit/init.lua`
- `lua/user/ai_edit/job.lua`
- `lua/user/ai_edit/review.lua`

Desired direction:

- `lua/user/ai/init.lua`
- `lua/user/ai/job.lua`
- `lua/user/ai/review.lua`

Reason:

- keep the namespace open for future AI-related workflows beyond edit review/apply
- avoid baking the current MVP name too deeply into the config before v2 work starts

### Small Operational Improvement

Add pruning:

- `:AIEditPrune`
- probably remove old `applied` / `failed` / maybe old `dismissed`
- keep `ready` / `stale` unless explicitly requested

### V2 Backlog

- floating prompt UI
- prettier notifications
- more top-level `setup()` options
- review annotations such as `>> note`
- `AIEditRevise` to resubmit with review notes
- optional better source-navigation helpers from review

## Summary

The MVP is working and feels coherent:

- async generation
- persisted artifacts
- review queue
- explicit apply
- stale protection
- dismiss path

The next best move is stabilization plus pruning, then a V2 focused on review iteration and lighter UI improvements rather than broader automation.
