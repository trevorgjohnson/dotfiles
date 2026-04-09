---
name: write-a-rule
version: 1.0.0
description: >-
  Create a new Claude Code rule file with proper frontmatter, path scoping,
  justification, and lint check. Use when user explicitly asks to create a
  new rule, write a rule, or add a standing instruction to the AI framework.
---

# Write a Rule

## Process

1. **Scan for overlap** — Glob `~/.config/dotfiles/ai/rules/` and
   `.claude/rules/`; list any rules that touch the same topic. Flag
   conflicts before proceeding.

2. **Structured intake** — use `AskUserQuestion` for:
   - **Scope**: global (`~/.config/dotfiles/ai/rules/`) or project
     (`.claude/rules/`)
   - **Paths**: file globs this rule applies to, or "none" for globally
     scoped rules
   - **Trigger context**: when/why should this rule fire? (free text)
   - **Rule body**: the instruction itself (free text)

3. **Draft** — enter `EnterPlanMode` and present the proposed file:
   - Frontmatter: `version`, `description`, optional `paths`
   - Rule body prose
   - HTML comment block with rationale (`<!-- Why: ... -->`)
   - Examples block — include only when the rule would be ambiguous
     without one; use judgment, don't always ask the user
   Exit plan mode after user approves.

4. **Write** — derive filename from the rule topic in kebab-case
   (e.g. `my-new-rule.md`). Write to the resolved path.

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
- [ ] `paths` is scoped if the rule is file-type-specific
- [ ] HTML comment justification block is present (`<!-- Why: ... -->`)
- [ ] No time-sensitive content (dates, versions, ticket numbers)
- [ ] `markdownlint` passes with no errors
- [ ] `version: 1.0.0` is set in frontmatter
