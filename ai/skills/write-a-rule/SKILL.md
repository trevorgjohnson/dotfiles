---
name: write-a-rule
version: 1.0.0
description: >-
  Create a new Claude Code rule file with proper frontmatter, path scoping,
  justification, and lint check. Use when user explicitly asks to create a
  new rule, write a rule, or add a standing instruction to the AI framework.
---

# Write a Rule

## Core Principles

- **One concern per file** — keep rules focused; security rules separate
  from styling rules
- **Targeted beats global** — rules without `paths` load in every session
  (context overhead); add path patterns whenever the rule is file-type- or
  domain-specific
- **Rules are elevated priority** — rule files receive higher weight than
  general context during generation, so put domain-specific mandates here
  rather than burying them in `CLAUDE.md`

## Process

1. **Scan for overlap** — Glob `~/.config/dotfiles/ai/rules/` and
   `.claude/rules/`; list any rules that touch the same topic. Flag
   conflicts before proceeding.

2. **Structured intake** — first confirm the right mechanism, then gather
   details via `AskUserQuestion`:

   **Mechanism check** — surface this table if the user hasn't already chosen:

   | Mechanism | Use when |
   | --- | --- |
   | `CLAUDE.md` | Universal workflows that apply everywhere |
   | Rules directory | Domain-specific patterns for paths or file types |
   | Skills | Cross-project knowledge triggered on demand |

   If rules are the right fit, ask:
   - **Scope**: global (`~/.config/dotfiles/ai/rules/`) or project (`.claude/rules/`)
   - **Paths**: file globs this rule applies to, or "none" for truly global rules.
     Omitting paths loads the rule in every session — wasteful for
     domain-specific rules.
     Supports brace expansion: `**/*.{ts,tsx}`, `{src,lib}/**/*`
   - **Trigger context**: when/why should this rule fire? (free text)
   - **Rule body**: the instruction itself (free text)

3. **Draft** — enter `EnterPlanMode` and present the proposed file:
   - Frontmatter: `version`, `description`, optional `paths`
   - Rule body prose
   - HTML comment block with rationale (`<!-- Why: ... -->`)
   - Examples block — include only when the rule would be ambiguous
     without one; use judgment, don't always ask the user
   Exit plan mode after user approves.

4. **Write** — choose a path within the rules directory:
   - Subdirectories are discovered recursively — group related rules under
     a folder (`frontend/`, `backend/`, `auth/`) rather than flattening
     everything at the root
   - Derive the leaf filename in kebab-case from the rule topic
     (e.g. `auth/no-sensitive-logging.md`, not `auth-no-sensitive-logging.md`)
   - Write to the resolved path.

5. **Lint** — run `npx markdownlint-cli <file>` and fix all errors.

## Rule File Template

```md
---
version: 1.0.0
description: >-
  One-line description of what this rule enforces.
paths:              # omit if the rule applies globally
  - '**/*.ts'
---

# Rule Name

[Rule body — the instruction Claude should follow.]

<!--
Why: [Rationale — motivation behind this rule.]
References: [link or prior incident, if applicable]
-->

<!-- Include only when rule is ambiguous without a concrete example -->
## Examples

**Incorrect:**
[violation]

**Correct:**
[compliant pattern]
```

## Review Checklist

After writing, verify:

- [ ] `description` is present in frontmatter
- [ ] `version: 1.0.0` is set in frontmatter
- [ ] Rule covers exactly one concern (not a grab-bag of unrelated guidelines)
- [ ] `paths` is as narrow as possible — global only if the rule truly
  applies everywhere
- [ ] HTML comment justification block is present (`<!-- Why: ... -->`)
- [ ] No time-sensitive content (dates, versions, ticket numbers)
- [ ] `markdownlint` passes with no errors
