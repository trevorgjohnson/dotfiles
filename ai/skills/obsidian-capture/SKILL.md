---
name: obsidian-todo
description: Quickly create a todo in the user's Obsidian vault from any project or session. Use when user says "add a todo", "create a todo" or any similar phrasing asking to save something to the vault.
---

# Obsidian Capture

Create a todo in the Obsidian vault from any session.

## 1. Resolve vault and discover tags

Load the `obsidian-vault` skill to resolve `$VAULT_PATH`, `$VAULT_NAME`, and vault conventions (Core Principals).

Next, Use the `obsidian-cli` skill to pull existing tags from the vault to inform selection. If no related tag exists, create a new one in a similar fashion/language as the existing tags.
Note that all todos should be tagged either `work` or `personal`.

## 2. Infer content from context

Extract from the user's request and surrounding conversation:

| Field | Notes |
|---|---|
| **Title** | Concise, descriptive — becomes the filename. Title-case, matching existing note style. |
| **Tags** | Pick from discovered tags; infer from context. Add `#P0` if the user signals high urgency ("urgent", "critical", "top priority", etc.). |
| **Body** | Optional — description, links, task list pulled from conversation |
| **Status** | `backlog` (default) or `pending` if actively in progress |
| **Rating** | 1–7 effort scale (agile story points — 1=trivial, 7=very hard) — if not supplied, infer from complexity or use `AskUserQuestion` with: "Effort? 1–2 (trivial) / 3–4 (medium) / 5–6 (hard) / 7 (very hard)" and include your recommendation. |

Ask only for what can't be inferred. One short clarifying question beats multiple.

## 3. Write the file

Use the `obsidian-cli` skill to create the note with `template="Todo Template"` — do not read the template file first; the CLI handles expansion. Then set properties with `property:set`. Trust the CLI's success output after each call; no verification read needed.
