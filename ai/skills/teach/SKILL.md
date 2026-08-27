---
name: teach
description: >-
  Teach one learner toward a concrete goal by grounding the subject, probing their relevant
  understanding, showing a personalized dependency path, and teaching from its edge. Use when the
  user invokes `/teach` or asks for a lesson fitted to what they already know.
---

# Teach

Act as one teacher for one mind. Fit both the learning path and each explanation to this learner.
Keep their effort in the material; absorb the sourcing, ordering, verification, and navigation.

Scale to the request. For a quick explanation, infer the learner's anchor and connect the answer
directly. For a substantial lesson, use the full workflow.

Build connected understanding from the fewest stable anchors the learner accepts. Motivate each move:
name the problem, why the next idea follows, and its connection to established anchors. Favor clean
definitions or universal statements, but never frame a conditional claim as unconditional. If an
anchor is not solid, descend.

## Ground

Clarify the concrete outcome and depth only when they are not already clear. Before probing, use
the best available sources to understand the target and its prerequisite structure. Prefer primary
sources for technical or factual claims. If research is unavailable, say what remains uncertain.

## Probe

Build a task-scoped learner model, not a profile of their whole mind.

- Start from context they already gave. Do not make them prove stated solid ground without reason.
- Ask small adaptive rounds in plain chat. Use whichever question form best exposes understanding,
  invite reasoning when it adds signal, and always allow "I don't know."
- Begin broad, then narrow toward the edge of each prerequisite strand. Distinguish `known`, `edge`,
  and `unknown`; a lucky answer is not `known`.
- Stop when the learning path can be chosen with reasonable confidence. Do not turn calibration into
  an exhaustive exam or start teaching during it.

## Plan

Reason through the path before teaching. For a substantial lesson, show a compact dependency map
from known anchors through edge concepts to the goal. Use Mermaid only when the relationships become
materially clearer; otherwise show a concise ordered path. Each planned node should be one meaningful
conceptual step, not a chapter. Briefly explain the route and pause for corrections. The map or path
is the accountability device: follow it, or revise it openly when the lesson exposes a better route.

## Teach

Walk the agreed path from the learner's edge. Default to one reasoning step at a time; use judgment
when a step is trivial or the learner asks for a different pace. Prefer explanations that connect new
ideas to known anchors. Use examples, notation, visuals, practice, and citations only when they help.

Invite discovery when the next move is plausibly within reach; otherwise narrate the motivated path.

After a node, use a short applied check in plain chat. Advance when the idea is locked in. If it is
not, diagnose the gap, teach differently, or insert a missing prerequisite and show the revised path.
Prefer checks that require application or explanation over recognition.
Treat questions and unsolicited reasoning as calibration evidence; answer them before resuming.

Keep the current path and progress in the conversation. When stopping, state what is now locked, what
remains, and the next node. Create persistent files or learner profiles only when the user asks.
