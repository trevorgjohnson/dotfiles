---
version: 1.0.1
paths:
  - '**/CLAUDE.md'
  - .claude/**/*.md
---

# Claude Code Documentation Standards

Guidelines for maintaining CLAUDE.md, rules, agents, skills, and memory files.

## CLAUDE.md

- **Hard limit**: 500 lines — do not exceed this
- **Target**: 200–300 lines for optimal adherence
- **Action at 300+ lines**: Review content and prioritize — move lower-priority or domain-specific instructions into
  `.claude/rules/` files (with path scoping where possible) to keep CLAUDE.md focused on high-priority,
  universally-applicable guidance
- CLAUDE.md is loaded in full on every session. Longer files waste context and reduce adherence to the instructions
  within them
- Content that belongs in CLAUDE.md: repo overview, architecture, critical safety rules (e.g., never run
  `terragrunt apply` without reviewing the plan), common workflows, environment setup
- Content that should move to rules: domain-specific conventions (naming, style), tool-specific patterns
  (Helm, Terraform), recurring operational procedures

## Rules (`.claude/rules/*.md`)

- Keep each file focused on a single topic
- Use `paths` frontmatter to scope rules to relevant file types when possible — this avoids loading rules into context
  when they aren't needed
- No hard line limit, but prefer concise files. If a rule file exceeds 100 lines, consider whether it should be split
- Include justification and references for each rule, wrapped in HTML comments (`<!-- -->`) placed directly below the
  rule they support. This keeps the reasoning accessible to humans reviewing the file without consuming Claude's
  context window

## Agents (`.claude/agents/*.md`)

- The agent description is loaded into the main session context at startup so Claude knows when to delegate — keep it
  concise
- The full system prompt body only loads when the agent is invoked, so length is less critical
- No hard line limit

## Skills (`.claude/skills/*/SKILL.md`)

- **Hard limit**: 500 lines — move detailed reference material to separate files in the skill directory
- Skill descriptions are loaded into context on every session with an aggregate budget of 2% of the context window
  (~16,000 characters across all skills). Exceeding this causes skills to be excluded — run `/context` to check
- Full skill content only loads when the skill is invoked

## Markdown Linting

All Claude Code documentation files (CLAUDE.md, rules, agents, skills) must pass `markdownlint`
using the default configuration (80-char line length). When creating or editing these files:

- Wrap prose at 80 characters
- Use blank lines around headings, code fences, lists, and tables
- Use `>-` for long `description` values in YAML frontmatter to keep them visually consistent
- Use `<!-- markdownlint-disable MD013 -->` / `<!-- markdownlint-enable MD013 -->` pragmas around content that genuinely
  cannot wrap (e.g., tables with long hostnames or URLs)
- Specify a language on all fenced code blocks (use `text` for plain output)
- **After creating or editing** any file matched by this rule's paths, run `npx markdownlint-cli <file>` and fix all
  errors before considering the task complete

## Memory (`MEMORY.md`)

- **Hard limit**: 200 lines — content beyond line 200 is not loaded at session start
- Keep it as an index with links to topic-specific files for detailed notes

<!--
These limits come from the Claude Code documentation:
- CLAUDE.md: "Longer files consume more context and reduce adherence." No hard truncation, but adherence degrades.
- SKILL.md: "Keep SKILL.md under 500 lines. Move detailed reference material to separate files."
- MEMORY.md: Lines after 200 are truncated at session start.
- Skill description budget: 2% of context window with a 16,000-character fallback.
-->
