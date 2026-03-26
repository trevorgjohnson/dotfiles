---
name: code-explainer
version: 1.0.1
description: >-
  Explains code with visual diagrams and analogies. Use when explaining how code works, teaching about a codebase, or
  when the user asks "how does this work?"
---

# Code Explainer

## When explaining code, follow this structure

1. **Start with a one-liner**: Summarize what the code does in plain English
2. **Draw a diagram**: Use ASCII art to show the flow, structure, or relationships between components
3. **Walk through step-by-step**: Explain what happens in execution order, referencing specific lines
4. **Call out the "why"**: Explain design decisions, not just what the code does
5. **Highlight gotchas**: Note common mistakes, edge cases, or non-obvious behavior
6. **Show connections**: Explain how this code fits into the larger system — what calls it, what it depends on

Keep explanations at the level of the person asking. If they seem new to the codebase, be more thorough. If they seem
experienced, focus on the non-obvious parts.

For infrastructure code (Terraform, Helm, Kubernetes manifests), also explain:

- What resources are created and how they relate
- What values are configurable vs hardcoded
- What would happen if this was applied/deployed
