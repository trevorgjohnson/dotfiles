---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Only trigger when user explicitly asks to create a new Claude Code skill.
---

# Writing Skills

## Process

1. **Gather requirements** — use `AskUserQuestion` with a structured prompt covering:
   - Domain / task the skill addresses
   - Specific use cases it must handle (ask for 2–3 concrete examples)
   - Whether it needs executable scripts or just instructions (Scripts / Instructions only / Both)
   - Reference materials to include (docs URLs, existing files, none)

2. **Draft the skill** — enter `EnterPlanMode` before presenting the proposed file structure and SKILL.md outline. Show:
   - Proposed file layout (`SKILL.md` + any supplementary files)
   - Section headings and 1-line description of each
   - Whether scripts will be included and their purpose
   Call `ExitPlanMode` after the user approves the outline, then write the files.

3. **Review with user** - present draft and ask:
   - Does this cover your use cases?
   - Anything missing or unclear?
   - Should any section be more/less detailed?

## Skill Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if needed)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
    └── helper.js
```

## SKILL.md Template

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See [REFERENCE.md](REFERENCE.md)]
```

## Description Requirements

The description is **the only thing your agent sees** when deciding which skill to load. It's surfaced in the system prompt alongside all other installed skills. Your agent reads these descriptions and picks the relevant skill based on the user's request.

**Goal**: Give your agent just enough info to know:

1. What capability this skill provides
2. When/why to trigger it (specific keywords, contexts, file types)

**Format**:

- Max 1024 chars
- Write in third person
- First sentence: what it does
- Second sentence: "Use when [specific triggers]"

**Good example**:

```
Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Bad example**:

```
Helps with documents.
```

The bad example gives your agent no way to distinguish this from other document skills.

## Built-in Tool Patterns

Every skill should use built-in tools where they add structure or safety. Apply these patterns during authoring:

| Pattern | Tool | When to use |
|---|---|---|
| Structured intake | `AskUserQuestion` | Any time the user needs to pick from a finite set of options (mode, type, environment, priority). Replace open-ended "ask the user" prose with a numbered multiple-choice prompt. |
| Approval gate | `EnterPlanMode` / `ExitPlanMode` | Wrap any "present a design or plan, then execute" step. Enter before showing the proposal; exit after the user approves. |
| Progress tracking | `TaskCreate` / `TaskUpdate` / `TaskList` | Multi-step workflows with 3+ discrete work items. Create tasks at the start of the phase; mark completed as each finishes. |
| Destructive confirmation | `AskUserQuestion` | Before any operation that overwrites, deletes, or can't be trivially undone. Offer: Confirm / Cancel / Preview first. |
| Auto-fetch on error | `WebFetch` | When a command fails and official docs exist — fetch them automatically rather than telling the user to check manually. |

When writing or reviewing a skill, ask for each workflow step: *could a built-in tool make this more structured, safer, or more visible to the user?*

## When to Add Scripts

Add utility scripts when:

- Operation is deterministic (validation, formatting)
- Same code would be generated repeatedly
- Errors need explicit handling

Scripts save tokens and improve reliability vs generated code.

## When to Split Files

Split into separate files when:

- SKILL.md exceeds 100 lines
- Content has distinct domains (finance vs sales schemas)
- Advanced features are rarely needed

## Review Checklist

After drafting, verify:

- [ ] Description includes triggers ("Use when...")
- [ ] SKILL.md under 100 lines
- [ ] No time-sensitive info
- [ ] Consistent terminology
- [ ] Concrete examples included
- [ ] References one level deep
- [ ] Finite-choice decisions use `AskUserQuestion` (not open-ended prose)
- [ ] Approval gates use `EnterPlanMode` / `ExitPlanMode`
- [ ] Multi-step workflows track progress with `TaskCreate` / `TaskUpdate`
- [ ] Destructive operations have a `AskUserQuestion` confirmation gate
- [ ] Error recovery fetches docs with `WebFetch` rather than deferring to the user
