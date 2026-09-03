---
name: deslop
description: Remove AI-generated code slop from a branch diff before commit. Use for /deslop, "deslop it", or cleaning narrating comments, defensive guards, and unrelated edits from the change.
---

# Remove AI code slop

Check the diff against main and remove AI-generated slop introduced in the branch.

## Focus Areas

- Extra comments that are unnecessary or inconsistent with local style, including narrating comments that restate the next line
- Defensive checks or try/catch blocks that are abnormal for trusted code paths
- Casts to `any` used only to bypass type issues
- Deeply nested code that should be simplified with early returns
- Dead compatibility paths and leftover shims the change no longer needs
- Unrelated edits that do not belong in this branch
- Other patterns inconsistent with the file and surrounding codebase

## Guardrails

- Keep behavior unchanged unless fixing a clear bug.
- Prefer minimal, focused edits over broad rewrites.
- Keep the final summary concise (1-3 sentences).
