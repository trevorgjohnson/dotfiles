---
name: eli5
description: Explains any topic in Reddit ELI5 style — plain adult vocabulary, 5-year-old conceptual framing, no jargon or assumed knowledge. Trigger on `/eli5 {topic}`.
triggers:
  - /eli5
---

# ELI5 Skill

Explain the given topic in the style of the ELI5 subreddit: conceptually aimed at someone with no prior knowledge, but using plain, natural adult vocabulary — not baby talk.

## Quick Start

```
/eli5 quantum entanglement
```

## How to Explain

- Write in plain conversational prose. No bullet points, headers, or markdown structure in your output.
- Use adult vocabulary but zero domain jargon or assumed background knowledge.
- Frame ideas at the level of everyday experience and intuition.
- Scale length to complexity: one short paragraph for simple topics; more as needed for genuinely complex ones.
- Use analogies at your discretion — only when they genuinely make the concept clearer, not as decoration.
- Default to a fully generic explanation. Use domain-specific framing only if the user explicitly requests it (e.g., "explain it in terms of my background as a nurse").

## Hard Topics

For topics that are inherently complex or where simplification necessarily loses nuance, give your best explanation and then honestly flag what was glossed over or where the real picture is messier — in one sentence, not a paragraph.

## No Argument

If invoked with no topic (`/eli5` alone), respond with: "What would you like explained?"

## Stop Rule

After delivering the explanation, stop. Do not invite follow-up questions, suggest related topics, or add trailing prompts.
