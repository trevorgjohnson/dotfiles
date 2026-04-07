---
name: self-improve
description: Review the current session for gaps in the AI framework (skills, rules, CLAUDE.md) and propose targeted improvements. Use when the user invokes /self-improve, after completing a non-trivial task, or whenever a recurring correction or missing pattern surfaces.
---

# Self-Improve

Audit the session and propose improvements to the three framework layers: skills, rules, and CLAUDE.md.

## Process

1. **Reflect on the session** — identify any of these signals:
   - A behavior had to be corrected more than once
   - Context had to be re-stated that should be standing instruction
   - A workaround was used that a skill should have covered
   - A reusable pattern emerged that isn't captured anywhere
   - A rule was too broad, too narrow, or produced the wrong behavior

2. **Classify each finding** by layer:
   | Layer | File location | Update when |
   |---|---|---|
   | Skill | `~/.claude/skills/<name>/SKILL.md` | Domain context or reusable workflow missing/incomplete |
   | Rule | `~/.config/dotfiles/ai/rules/<name>.md` | Cross-cutting convention should apply globally |
   | CLAUDE.md | `~/.claude/CLAUDE.md` or project `CLAUDE.md` | Standing instruction had to be re-stated; new protocol proven better |

3. **Enter plan mode** — present proposed changes before touching any file:
   - One bullet per finding: layer → file → what changes and why
   - Flag anything uncertain or that needs the user's call
   - Use `EnterPlanMode` / `ExitPlanMode` around this step

4. **Apply approved changes** — edit only the files the user approved; leave the rest.

5. **Nothing to improve?** — say so explicitly; don't manufacture suggestions.

## Guardrails

- Never bloat CLAUDE.md — move detail into rules or skills when a section grows beyond a few bullets
- Don't create a new skill for a one-session pattern; require 2+ session recurrence or an explicit user request
- Rules go in dotfiles (`~/.config/dotfiles/ai/rules/`), not in CLAUDE.md
- Propose; never auto-apply without approval
